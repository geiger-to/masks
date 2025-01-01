# frozen_string_literal: true

module Masks
  class AuthorizationCode < Token
    cleanup :expires_at do
      0.seconds
    end

    validates :code_challenge_method,
              inclusion: {
                in: Masks::Client::CODE_CHALLENGE_METHODS,
              },
              if: :code_challenge

    setting :code_challenge
    setting :code_challenge_method

    def pkce?
      code_challenge && code_challenge_method
    end

    def obfuscated_code
      obfuscate(:code)
    end

    def access_token
      @access_token ||=
        update_attribute!(:expires_at, Time.now) && generate_access_token!
    end

    def generate_access_token!
      return if expires_at > Time.current

      Masks::AccessToken.copy!(self)
    end
  end
end
