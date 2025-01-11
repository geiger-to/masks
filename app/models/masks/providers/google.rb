module Masks
  module Providers
    class Google < Provider
      def omniauth_strategy
        OmniAuth::Strategies::GoogleOauth2
      end
    end
  end
end
