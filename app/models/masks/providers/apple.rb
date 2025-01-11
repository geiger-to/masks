module Masks
  module Providers
    class Apple < Provider
      def omniauth_strategy
        OmniAuth::Strategies::Apple
      end
    end
  end
end
