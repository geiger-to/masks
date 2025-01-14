module Masks
  module Prompts
    class Device
      include Masks::Prompt

      match { device }

      before_entry do
        if device.blocked?
          warn! "blocked-device", prompt: "device"
        elsif !device.valid_request?(request)
          warn! "invalid-device", prompt: "device"
        end
      end
    end
  end
end
