module Masks
  module Providers
    class Twitter < Provider
      def omniauth_strategy
        OmniAuth::Strategies::Twitter
      end
    end
  end
end
