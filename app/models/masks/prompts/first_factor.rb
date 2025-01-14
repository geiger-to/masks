module Masks
  module Prompts
    class FirstFactor
      include Masks::Prompt

      match { actor && !checked?(Entry::FACTOR1) }

      prompt "first-factor" do
        true
      end
    end
  end
end
