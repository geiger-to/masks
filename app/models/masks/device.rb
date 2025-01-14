# frozen_string_literal: true

module Masks
  class Device < ApplicationRecord
    COOKIE = "masks_device"

    self.table_name = "masks_devices"

    include Cleanable

    cleanup :updated_at do
      Masks.installation.duration(:devices, :lifetime)
    end

    attribute :request

    has_many :tokens, class_name: "Masks::Token"
    has_many :actors,
             -> { distinct },
             class_name: "Masks::Actor",
             through: :tokens
    has_many :clients,
             -> { distinct },
             class_name: "Masks::Client",
             through: :tokens

    validates :public_id, presence: true, uniqueness: true
    validates :known?, :user_agent, presence: true
    validates :ip_address, ip: true

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

    def rotate
      self.version += 1
    end

    def logout!
      transaction do
        rotate
        tokens.usable.find_each(&:revoke!)
        save!
      end
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

    def valid_request?(request)
      validate

      errors.add(:user_agent, :mismatch) if request.user_agent != user_agent
      errors.add(:ip_address, :mismatch) if request.remote_ip != ip_address
      errors.none?
    end

    private

    def detected
      @detected ||= DeviceDetector.new(user_agent) if user_agent
    end

    def generate_defaults
      self.version ||= 0
    end

    def validate_request
    end
  end
end
