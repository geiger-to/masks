module Masks
  module Prompts
    class SecondFactor
      include Masks::Prompt

      match :on_2fa?

      prompt "profile" do
        if !actor.second_factor? && client.second_factor?
          extras(second_factor_required: true)
        end
      end

      prompt "second-factor" do
        !checked?(Entry::FACTOR2)
      end

      event "second-factor:enable", if: -> { !actor.second_factor? } do
        actor.enable_second_factor!
      end
    end
  end
end
