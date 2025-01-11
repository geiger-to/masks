module Masks
  module Providers
    class Facebook < Provider
      def omniauth_strategy
        OmniAuth::Strategies::Facebook
      end
    end
  end
end
