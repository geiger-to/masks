module Masks
  class Device < ApplicationModel
    attribute :session

    def fingerprint
      return unless detector.known?

      input = [
        detector.name,
        detector.os_name,
        detector.device_name,
        detector.device_type
      ].compact.join("-")

      Digest::SHA512.hexdigest(input)
    end

    def detector
      @detector ||= DeviceDetector.new(session.user_agent)
    end
  end
end
