# frozen_string_literal: true

module Masks
  module Credentials
    # Assigns the request URL to session data, under the key +return_to+.
    #
    # This credential is intended to keep track of an actor's attempts to
    # access protected resources, so it only assigns the value if the session
    # has not passed.
    #
    # In some cases, you may want to selectively disable the functionality
    # of this credential. To do so, set +return_to+ to +false+ in the
    # mask configuration.
    class ReturnTo < Masks::Credential
      def backup
        return if session&.passed?
        return unless session.try(:request) && session.request.get?
        if session.mask.extras.key?(:return_to) &&
             !session.mask.extras[:return_to]
          return
        end

        session.data[:return_to] = session.request.url
      end
    end
  end
end
