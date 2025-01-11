module Masks
  module Providers
    class Github < Provider
      def omniauth_strategy
        OmniAuth::Strategies::GitHub
      end
    end
  end
end
