module Masks
  module TestActors
    class Test < ApplicationModel
      include Masks::Actor

      attribute :nickname
      attribute :session

      def actor_id
        @actor_id ||= SecureRandom.hex
      end

      def scopes
        ["test"]
      end

      def mask!
        self.session = session
      end
    end
  end
end
