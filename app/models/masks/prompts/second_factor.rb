module Masks
  module Prompts
    class SecondFactor < Base
      checks "second-factor"

      def enabled?
        super && second_factor_enabled?
      end

      prompt "second-factor" do
        checking?("second-factor") || !actor.second_factor? ||
          actor.review_second_factor?
      end

      event "second-factor:enable" do
        # only allowed when first enabling second factor options, atm
        return if actor.second_factor?

        actor.enable_second_factor!
      end
    end
  end
end
