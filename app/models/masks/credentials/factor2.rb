# frozen_string_literal: true

module Masks
  module Credentials
    # Base class for factor2 credentials.
    module Factor2
      extend ActiveSupport::Concern

      included do
        validates :secret, presence: true, if: :enabled?
        validates :code, presence: { allow_nil: true }

        attribute :code

        checks :factor2
      end

      def lookup
        # nothing to do here
      end

      def maskup
        check.optional = false if actor&.factor2?

        return unless enabled?

        code_param = session_params&.fetch(param, nil)&.presence

        self.code = verify(code_param) if code_param

        if code
          approve!
        elsif code_param
          deny!
        end
      end

      def verified?
        code
      end

      def enabled?
        secret.present?
      end

      def param
        raise NotImplementedError
      end

      def secret
        raise NotImplementedError
      end

      def enable(code, secret:)
        raise NotImplementedError
      end

      def verify(code)
        raise NotImplementedError
      end

      def verify_on_enable?
        false
      end

      def generate_secret
        nil
      end
    end
  end
end
