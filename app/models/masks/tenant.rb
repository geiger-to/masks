# frozen_string_literal: true

module Masks
  class Tenant < ApplicationRecord
    self.table_name = "masks_tenants"

    validates :key, presence: true, uniqueness: true

    has_many :profiles, class_name: "Masks::Profile"
    has_many :actors, class_name: "Masks::Actor"
    has_many :clients, class_name: "Masks::Client"
    has_many :authorizations, class_name: "Masks::Authorization"
    has_many :access_tokens, class_name: "Masks::AccessToken"
    has_many :devices, class_name: "Masks::Device"
    has_many :interactions, class_name: "Masks::Interaction"

    belongs_to :client, class_name: "Masks::Client", optional: true
    belongs_to :admin, class_name: "Masks::Client", optional: true

    after_initialize :populate_settings, if: :new_record?

    serialize :settings, coder: JSON

    def name
      super || setting(:name)
    end

    def redirect_uri
      setting(:url)
    end

    def seeded?
      seeded_at.present?
    end

    def setting(*args)
      settings.dig(*args.map(&:to_s))
    end

    def enabled?(key)
      settings.dig(key.to_s, "enabled")
    end

    def openid?
      false
    end

    def find_actor(identifier: nil, uuid: nil)
      if uuid
        actors.find_by(uuid:)
      elsif identifier
        id =
          (
            if identifier.is_a?(Masks::Identifier)
              identifier
            else
              self.identifier(value: identifier)
            end
          )

        return unless id

        actors.includes(:identifiers).find_by(
          identifiers: {
            value: id.value,
            type: id.type
          }
        )
      end
    end

    def identifiers
      {
        email: Masks::Identifiers::Email,
        nickname: Masks::Identifiers::Nickname,
        phone: Masks::Identifiers::Phone
      }.map { |key, cls| [key, cls] if enabled?(key) }
        .compact
        .to_h
        .with_indifferent_access
    end

    def identifier(
      value:,
      key: nil,
      identifiers: self.identifiers,
      profile: nil
    )
      return if !value || (key && !identifiers[key])

      if key
        id = identifiers[key].new(key:, tenant: self, profile:, value:)
        id if id.match?
      else
        identifiers.each do |key, cls|
          id = cls.new(key:, tenant: self, profile:, value:)

          return id if id.match?
        end

        nil
      end
    end

    def profile(key)
      profiles.find_by!(key:)
    rescue ActiveRecord::RecordNotFound
      raise Masks::Error::ProfileNotFound
    end

    private

    def populate_settings
      self.settings =
        Masks.configuration.data.deep_merge(settings || {}).deep_stringify_keys
      self.version ||= SecureRandom.uuid
    end
  end
end
