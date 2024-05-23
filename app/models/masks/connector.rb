# frozen_string_literal: true

module Masks
  # A base class for credentials, which identify actors and check their access.
  #
  # When a session is masked, a set of credentials are given the chance to
  # inspect the session parameters, propose an actor, and approve or deny
  # their access.
  #
  # There are a few lifecycle methods available to credentials:
  #
  # - +lookup+  - should return an identified actor if found
  # - +maskup+  - validates the session, actor, and any other data
  # - +backup+  - records the status of the credential's check(s), if necessary
  # - +cleanup+ - deletes any recorded data for the credential
  #
  # Sessions expect credentials to use checks to record their results, so there
  # are helper methods to approve or deny associated checks.
  #
  # @see Masks::Check Masks::Check
  # @see Masks::Credentials Masks::Credentials
  class Connector < ApplicationModel
    class << self
      def key(value = nil)
        @key = value if value
        @key
      end
    end

    attribute :request

    def initialize(request)
      super(request:)
    end

    delegate :profile, :tenant, :params, to: :request

    # return an actor if it's found and valid
    def actor
      nil
    end

    def mask!
    end

    # def mask!
    #   before_mask

    #   # existing checks (found from the session) can be
    #   # skipped when already present and not expired
    #   return if check&.passed? && check.attempts[slug] && valid?

    #   self.masked_at = Time.current

    #   maskup
    # end

    # # verify the session and actor
    # def maskup
    #   nil
    # end

    # def backup!
    #   self.passed_at = Time.current if check&.passed? &&
    #     check&.attempt_approved?(slug)

    #   backup
    # end

    # # write any data after all credentials/checks have run
    # def backup
    #   nil # but overridable
    # end

    # # cleanup data re: the mask
    # def cleanup
    #   nil # but overridable
    # end

    # def cleanup!
    #   cleanup
    #   reset!
    # end

    # delegate :optional?,
    #          :passed?,
    #          :invalidated?,
    #          to: :check,
    #          allow_nil: true

    # def slug
    #   self.class.name.split("::").join("_").underscore.to_sym
    # end

    # def name
    #   I18n.t("masks.credentials.#{slug}.name")
    # end

    # def check
    #   session&.find_check(self.class.checks)
    # end

    # def patch_params
    #   session&.account_params&.fetch(slug, {})
    # end

    # private

    # def before_mask
    #   nil
    # end

    # def approve!(**opts)
    #   check&.approve!(slug, **opts)
    # end

    # def deny!(**opts)
    #   check&.deny!(slug, **opts)
    # end

    # def fail!(**opts)
    #   deny!(**opts)

    #   raise Masks::Error::CheckFailed, self
    # end

    # def reset!
    #   check&.clear!(slug)
    # end
  end
end
