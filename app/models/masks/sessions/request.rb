# frozen_string_literal: true

module Masks
  module Sessions
    # Session for masking +ActionDispatch::Request+ and +Rack::Request+.
    class Request < Masks::Session
      attribute :request

      def to_s
        "mask(#{request.method.upcase} #{request.path})"
      end

      def ip_address
        request.remote_ip
      end

      def user_agent
        request.user_agent
      end

      def fingerprint
        params[:_fingerprint]
      end

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
