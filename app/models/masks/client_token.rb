# frozen_string_literal: true

module Masks
  class ClientToken < AccessToken
    cleanup :expires_at do
      0.seconds
    end

    private

    def validate_entry?
      false
    end
  end
end
