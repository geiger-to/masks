# frozen_string_literal: true

module Masks
  class Device < ApplicationRecord
    self.table_name = "masks_devices"

    include Cleanable

    cleanup :updated_at do
      Masks.installation.duration(:devices, :lifetime)
    end

    attribute :request
    attribute :check

    has_many :tokens, class_name: "Masks::Token"
    has_many :entries, class_name: "Masks::Entry"
    has_many :actors,
             -> { distinct },
             class_name: "Masks::Actor",
             through: :entries
    has_many :clients,
             -> { distinct },
             class_name: "Masks::Client",
             through: :entries

    validates :public_id, presence: true, uniqueness: true
    validates :known?, :user_agent, presence: true
    validates :ip_address, ip: true
    validate :validate_request, on: :session
    validate :validate_check, on: :session

    delegate :name,
             :device_type,
             :device_name,
             :os_name,
             :known?,
             to: :detected,
             allow_nil: true

    after_initialize :generate_defaults

    def session_key
      [public_id, version].join("-")
    end

    def logout
      self.version += 1
    end

    def logout!
      logout
      save!
    end

    def block
      self.blocked_at = Time.now.utc
    end

    def unblock
      self.blocked_at = nil
    end

    def block!
      block
      save!
    end

    def blocked?
      blocked_at && Masks.time.expired?(blocked_at)
    end

    private

    def detected
      @detected ||= DeviceDetector.new(user_agent) if user_agent
    end

    def generate_defaults
      self.version ||= 0
    end

    def validate_check
      return errors.add(:check, :blank) unless check

      return unless check.device_version&.present?

      errors.add(:version, :mismatch) if check.device_version != version
    end

    def validate_request
      return errors.add(:request, :blank) unless request

      errors.add(:user_agent, :mismatch) if request.user_agent != user_agent

      errors.add(:ip_address, :mismatch) if request.remote_ip != ip_address
    end
  end
end
