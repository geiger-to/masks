module Masks
  module Prompts
    class Credentials < Base
      prompt "credentials" do
        identifier && !checked?("credentials")
      end
    end
  end
end
