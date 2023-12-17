module Masks
  module TestCredentials
    class Param < Masks::Credential
      checks :param

      validates :nickname, presence: true, length: { minimum: 5 }
      delegate :nickname, to: :actor, allow_nil: true

      def lookup
        Masks::TestActors::Test.new(params) if params[:nickname]
      end

      def maskup
        approve! if params[:nickname] == actor&.nickname && valid?
      end
    end
  end
end
