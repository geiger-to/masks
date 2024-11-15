module Masks
  module Checks
    class Base < ApplicationModel
      attribute :state

      delegate :client, to: :state
      delegate :expires_at, to: :client

      def checked!(**args)
        raise NotImplementedError
      end

      def checked?
        raise NotImplementedError
      end
    end
  end
end
