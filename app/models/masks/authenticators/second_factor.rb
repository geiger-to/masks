module Masks
  module Authenticators
    class SecondFactor < Base
      def enabled?
        client.require_second_factor? || actor&.second_factor?
      end

      prompt "second-factor" do
        second_factor_expired?
      end

      event "second-factor:enable" do
        return if !actor || actor.second_factor?

        actor.enable_second_factor!
      end
    end
  end
end
