module Masks
  module Sessions
    class Request < Masks::Session
      attribute :request

      def params
        request.params
      end

      def data
        request.session
      end

      def matches_mask?(mask)
        mask.matches_request?(request)
      end

      def writable?
        request.post?
      end
    end
  end
end
