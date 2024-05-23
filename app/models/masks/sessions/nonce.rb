# frozen_string_literal: true

module Masks
  module Sessions
    class Nonce < ApplicationModel
      attribute :request
      attribute :tenant

      def to_s
        value
      end

      def redirect_uri=(uri)
        data["redirect_uri"] = uri
      end

      def redirect_uri
        data["redirect_uri"]
      end

      def hint=(value)
        data["hint"] = value if value
      end

      def hint
        data["hint"]
      end

      def clear_hint
        self.hint = nil

        data["hint"] = nil
      end

      def openid_params
        @openid_params ||= if openid_qs
          Rack::Utils.parse_query(openid_qs).with_indifferent_access
        end
      end

      def openid_qs=(value)
        data["openid_qs"] = value
      end

      def openid_qs
        data["openid_qs"]
      end

      def value
        request.session["#{tenant_key}:nonce"] ||= SecureRandom.uuid
      end

      def value=(value)
        return unless value

        request.session["#{tenant_key}:nonce"] ||= value
        request.session["#{tenant_key}:nonces"] ||= {}
        request.session["#{tenant_key}:nonces"][value] ||= {}
      end

      def data
        request.session["#{tenant_key}:nonces"] ||= {}
        request.session["#{tenant_key}:nonces"][value] ||= {}
      end

      def tenant_key
        "masks:#{tenant.version}"
      end
    end
  end
end
