module Masks
  module Actors
    class System < ApplicationModel
      include Masks::Actor

      attribute :session

      def nickname
        @nickname ||= "system:#{SecureRandom.hex}"
      end

      def scopes
        []
      end

      def mask!
        true
      end
    end
  end
end
