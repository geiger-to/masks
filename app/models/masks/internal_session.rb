module Masks
  class InternalSession < ApplicationModel
    class << self
      def from_request(request:, client:)
        new(auth: Masks::Auth.new(request:, client:))
      end
    end

    attribute :auth

    def auth!(&block)
      auth.session!(&block)
    end

    delegate :current_actor, :device, to: :prompt
    delegate :masks_manager?, to: :current_actor, allow_nil: true

    private

    def prompt
      auth.prompt_for(Masks::Prompts::InternalSession)
    end
  end
end
