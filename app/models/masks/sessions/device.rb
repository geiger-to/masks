# frozen_string_literal: true

module Masks
  module Sessions
    class Device < ApplicationModel
      attribute :request
      attribute :tenant
      attribute :client
      attribute :actor

      def device_id
        request.session["masks:device_id"] ||= SecureRandom.hex(16)
      end

      def record
        @record ||= begin
          device = tenant.devices.find_or_initialize_by(key: device_id)
          device.user_agent = request.user_agent if device.new_record?
          device.ip_address = request.remote_ip if device.new_record?
          device
        end
      end

      delegate :known?, :name, :device_type, :device_name, :os_name, to: :record
    end
  end
end
