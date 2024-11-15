module Masks
  module Prompts
    class Factor2 < Base
      def enabled?
        (client.require_second_factor? || actor.second_factor?) &&
          checked?(:identifier, :first) && !checked?(:second)
      end

      prompt "second-factor" do
        !checked?(:second)
      end

      event "second-factor:enable" do
        # only allowed when first enabling second factor options, atm
        return if actor.second_factor?

        actor.enable_second_factor!
      end
    end
  end
end
