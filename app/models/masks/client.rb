# frozen_string_literal: true

module Masks
  class Client < ApplicationRecord
    include Masks::Scoped

    MANAGE_KEY = 'manage'
    DEFAULT_KEY = 'default'

    self.table_name = "masks_clients"

    scope :default, -> { find_by(key: DEFAULT_KEY) }
    scope :manage, -> { find_by(key: MANAGE_KEY) }

    validates :name, presence: true

    after_initialize :generate_credentials
    before_validation :generate_key, unless: :key, on: :create

    serialize :scopes, coder: JSON
    serialize :redirect_uris, coder: JSON
    serialize :response_types, coder: JSON
    serialize :grant_types, coder: JSON

    validates :key, :secret, :redirect_uris, presence: true
    validates :key, uniqueness: true
    validates :client_type,
              inclusion: {
                in: %w[internal public confidential],
              },
              presence: true
    validates :subject_type, inclusion: { in: :subject_types }, presence: true
    validate :validate_expiries

    has_many :access_tokens,
             class_name: "Masks::AccessToken",
             inverse_of: :client
    has_many :authorizations,
             class_name: "Masks::Authorization",
             inverse_of: :client
    has_many :devices, class_name: "Masks::Device", through: :access_tokens

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

    def default_redirect_uri
      redirect_uris.first
    end

    def valid_redirect_uri?(uri)
      return false unless uri&.present?

      if internal?
        uri.start_with?("/") ||
          redirect_uris.any? do |redirect_uri|
            uri.start_with?(redirect_uri) || uri == redirect_uri
          end
      else
        redirect_uris.include?(uri)
      end
    end

    def subject_types
      pairwise_subject? ? ["pairwise"] : ["public"]
    end

    def response_types
      {
        "internal" => [],
        "confidential" => ["code"],
        "public" => ["token", "id_token", "id_token token"],
      }.fetch(client_type, [])
    end

    def grant_types
      case client_type
      when "internal"
        %w[client_credentials]
      when "confidential"
        %w[refresh_token authorization_code client_credentials]
      else
        []
      end
    end

    def scopes
      self[:scopes]
    end

    def issuer
      Masks::Engine.routes.url_helpers.openid_issuer_url(id: key, host: "TODO")
    end

    def kid
      :default
    end

    def private_key
      OpenSSL::PKey::RSA.new(rsa_private_key)
    end

    delegate :public_key, to: :private_key

    def subject(actor)
      case subject_type
      when "public"
        actor.key
      else
        Digest::SHA256.hexdigest(
          [
            sector_identifier,
            actor.uuid,
            setting(:openid, :pairwise_salt),
          ].join("/"),
        )
      end
    end

    def audience
      key
    end

    def auto_consent?
      !consent
    end

    def pairwise_subject?
      sector_identifier && subject_type == "pairwise"
    end

    def assign_scopes!(*scopes)
      self.scopes = [*scopes, *self.scopes].uniq.compact
      save!
    end

    def remove_scopes!(*scopes)
      scopes.each { |scope| self.scopes.delete(scope) }

      save!
    end

    def code_expires_at
      Time.now + ChronicDuration.parse(code_expires_in)
    end

    def id_token_expires_at
      Time.now + ChronicDuration.parse(id_token_expires_in)
    end

    def access_token_expires_at
      Time.now + ChronicDuration.parse(access_token_expires_in)
    end

    def refresh_expires_at
      Time.now + ChronicDuration.parse(refresh_expires_in)
    end

    private

    def generate_credentials
      self.secret ||= SecureRandom.uuid
      self.client_type ||= "confidential"
      self.subject_type ||= "public"
      self.scopes ||= setting(:openid, :scopes) || []
      self.rsa_private_key ||= OpenSSL::PKey::RSA.generate(2048).to_pem
      self.sector_identifier ||=
        begin
          URI.parse("TODO").host
        rescue StandardError
          "masks"
        end
      self.code_expires_in ||= "5 minutes"
      self.access_token_expires_in ||= "1 day"
      self.id_token_expires_in ||= "1 hour"
      self.refresh_expires_in ||= "1 week"
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
      %i[
        code_expires_in
        id_token_expires_in
        access_token_expires_in
        refresh_expires_in
      ].each do |param|
        value = send(param)
        errors.add(param, :invalid) unless value && ChronicDuration.parse(value)
      end
    end
  end
end
