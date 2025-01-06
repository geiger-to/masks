# frozen_string_literal: true

module Masks
  class Client < ApplicationRecord
    CODE_CHALLENGE_METHODS = %w[S256 plain]
    MANAGE_KEY = "manage"
    DEFAULT_KEY = "default"
    LIFETIME_COLUMNS = %i[
      id_token_expires_in
      access_token_expires_in
      authorization_code_expires_in
      refresh_token_expires_in
      client_token_expires_in
      login_link_expires_in
      auth_attempt_expires_in
      email_verification_expires_in
      login_link_factor_expires_in
      password_factor_expires_in
      second_factor_backup_code_expires_in
      second_factor_phone_expires_in
      second_factor_totp_code_expires_in
      second_factor_webauthn_expires_in
      internal_token_expires_in
    ]

    BOOLEAN_COLUMNS = %i[
      allow_passwords
      allow_login_links
      autofill_redirect_uri
      fuzzy_redirect_uri
    ]

    STRING_COLUMNS = %i[
      client_type
      sector_identifier
      subject_type
      bg_light
      bg_dark
    ]

    SETTING_COLUMNS = [
      *LIFETIME_COLUMNS,
      *BOOLEAN_COLUMNS,
      *STRING_COLUMNS,
      :scopes,
      :response_types,
    ]

    self.table_name = "masks_clients"

    has_one_attached :logo do |attachable|
      attachable.variant :preview,
                         resize_to_limit: [500, 500],
                         preprocessed: true
    end

    scope :default, -> { find_by(key: DEFAULT_KEY) }

    class << self
      def manage
        find_by(key: MANAGE_KEY)
      end
    end

    validates :name, presence: true

    encrypts :secret, :pairwise_salt, :rsa_private_key

    after_initialize :generate_credentials
    before_validation :generate_key, unless: :key, on: :create

    validates :key, :secret, presence: true
    validates :key, uniqueness: true
    validates :client_type,
              inclusion: {
                in: -> { Masks.setting(:clients, :types) },
              },
              presence: true
    validates :subject_type,
              inclusion: {
                in: -> { Masks.setting(:clients, :subject_types) },
              },
              presence: true
    validate :validate_expiries

    has_many :tokens, class_name: "Masks::Token", inverse_of: :client
    has_many :login_links, class_name: "Masks::LoginLink"
    has_many :actors,
             -> { distinct },
             class_name: "Masks::Actor",
             through: :tokens
    has_many :devices,
             -> { distinct },
             class_name: "Masks::Device",
             through: :tokens

    serialize :checks, coder: JSON
    serialize :scopes, coder: JSON
    serialize :grant_types, coder: JSON
    serialize :response_types, coder: JSON

    def scope
      @scope ||= ClientScope.new(self)
    end

    def checks
      current = Masks::Checks.names(super || [])

      Masks.installation.checks.select { |name| current.include?(name) }
    end

    def check?(cls)
      checks.include?(Masks::Checks.to_name(cls))
    end

    def remove_check!(name)
      name = Masks::Checks.to_name(name)

      self.checks = checks.filter { |c| c != name }

      save!
    end

    def add_check!(name)
      update!(checks: [*checks, Masks::Checks.to_name(name)])
    end

    def logo_url
      if logo&.attached?
        Rails.application.routes.url_helpers.rails_storage_proxy_url(
          logo.variant(:preview),
        )
      end
    end

    def to_gqlid
      "client:#{key}"
    end

    def setting(*args)
      nil
    end

    def to_param
      key
    end

    def internal?
      client_type == "internal"
    end

    def pkce?
      client_type == "public"
    end

    def default_redirect_uri
      redirect_uris_a.first
    end

    def redirect_uris
      super || ""
    end

    def redirect_uris_a
      redirect_uris.split("\n")
    end

    def valid_response_type?(value)
      return false unless value&.present?

      response_types.include?(value)
    end

    def valid_grant_type?(value)
      return false unless value&.present?

      grant_types.include?(value.to_s)
    end

    def valid_redirect_uri?(uri)
      uri = uri.to_s

      return false if uri.start_with?("/") && !internal?

      if fuzzy_redirect_uri?
        redirect_uris_a.any? do |redirect_uri|
          Fuzzyurl.matches?(Fuzzyurl.mask(redirect_uri), uri)
        end
      else
        redirect_uris_a.include?(uri)
      end
    end

    def valid_pkce_request?(response_type:, challenge:, method:)
      pkce_required = client_type == "public"
      pkce_request = response_type.include?("code")

      if pkce_required && pkce_request
        challenge&.present? && CODE_CHALLENGE_METHODS.include?(method)
      else
        true
      end
    end

    def subject_types
      [subject_type.split("-").first] # one of pairwise or public
    end

    def issuer
      Masks.url
    end

    def kid
      :default
    end

    def private_key
      OpenSSL::PKey::RSA.new(rsa_private_key)
    end

    delegate :public_key, to: :private_key

    def subject(actor)
      type, attr = subject_type.split("-")
      value =
        case attr
        when "identifier"
          actor.identifier
        when "uuid"
          actor.key
        end

      case type
      when "public"
        value
      else
        "pairwise"
        Digest::SHA256.hexdigest(
          [sector_identifier, value, pairwise_salt].join("+"),
        )
      end
    end

    def audience
      key
    end

    def login_links?
      allow_login_links? && Masks.installation.login_links?
    end

    def auto_consent?
      internal? || !check?("client-consent")
    end

    def expires_at(type = nil, custom: nil)
      if custom
        Masks.time.expires_at(custom)
      else
        column = "#{type.to_s.delete_suffix("_expires_in")}_expires_in".to_sym

        return unless LIFETIME_COLUMNS.include?(column) && self[column]

        Masks.time.expires_at(self[column])
      end
    end

    def email_verification_duration
      ChronicDuration.parse(email_verification_expires_in)
    end

    def authorize_params(params)
      params = params.merge(scope: scope.minimum(params[:scope]).join(" "))

      if internal?
        { redirect_uri: default_redirect_uri }.merge(params).merge(
          response_type: "code",
        )
      else
        params
      end
    end

    def logout
      nil
    end

    def valid_secret?(secret)
      return false unless secret&.present? && self.secret&.present?

      ActiveSupport::SecurityUtils.secure_compare(secret, self.secret)
    end

    def bearer_token!(scopes:)
      ClientToken.create!(client: self, scopes:).to_bearer_token
    end

    private

    def generate_credentials
      self.secret ||= SecureRandom.base58(64)
      self.rsa_private_key ||= OpenSSL::PKey::RSA.generate(2048).to_pem
      self.checks = Masks.installation.client_checks unless checks.any?
      self.sector_identifier ||= Masks.url
      self.pairwise_salt ||= SecureRandom.hex(10)

      SETTING_COLUMNS.each { |key| self[key] ||= Masks.setting(:clients, key) }

      self.grant_types ||= Masks.setting(:clients, :grant_types, client_type)
    end

    def generate_key
      return unless name

      key = name.parameterize

      loop do
        break if self.class.where(key:).none?

        key = "#{name.parameterize}-#{SecureRandom.hex([*1..4].sample)}"
      end

      self.key = key
    end

    def validate_expiries
      LIFETIME_COLUMNS.each do |param|
        raise "invalid" unless self[param] && ChronicDuration.parse(self[param])
      rescue StandardError
        errors.add(param, :invalid)
      end
    end
  end
end
