# frozen_string_literal: true

module Masks
  class Device < ApplicationRecord
    self.table_name = "masks_devices"

    has_many :access_tokens, class_name: "Masks::AccessToken"
    has_many :clients, through: :access_tokens, class_name: "Masks::Client"
    has_many :actors, through: :access_tokens, class_name: "Masks::Actor"

    validates :key, presence: true, uniqueness: true
    validates :known?, :user_agent, presence: true
    validates :ip_address, ip: true

    after_initialize :reset_version, unless: :version

    def expire!(actor: nil, all: false)
      actor = actor ? actors.find_by(key: actor) : nil
      tokens =
        if actor
          access_tokens.where(actor:)
        elsif all
          access_tokens
        else
          []
        end

      return unless tokens.any?

      tokens.update_all(revoked_at: Time.current)
    end

    def session_key
      Digest::SHA512.hexdigest([key, version].join("-"))
    end

    def reset_version
      self.version = SecureRandom.hex
    end

    delegate :name, :device_type, :device_name, :os_name, :known?, to: :detected

    private

    def detected
      @detected ||= DeviceDetector.new(user_agent) if user_agent
    end
  end
end
