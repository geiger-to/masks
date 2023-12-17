# frozen_string_literal: true

module Masks
  module Rails
    class Device < ApplicationRecord
      self.table_name = "devices"

      attribute :session

      belongs_to :actor, class_name: Masks.configuration.models[:actor]

      validates :key, presence: true, uniqueness: { scope: :actor_id }
      validates :known?, presence: true

      after_initialize :reset_version, unless: :version
      before_validation :copy_session, if: :session

      def known?
        session.device&.known?
      end

      def session_key
        Digest::SHA512.hexdigest([key, version].join("-"))
      end

      def reset_version
        self.version = SecureRandom.hex
      end

      delegate :name, :device_type, :device_name, :os_name, to: :detected

      private

      def detected
        @detected ||= DeviceDetector.new(user_agent || session&.user_agent)
      end

      def copy_session
        return unless known?

        self.user_agent ||= session.user_agent
        self.ip_address ||= session.ip_address
        self.fingerprint ||= session.fingerprint
      end
    end
  end
end
