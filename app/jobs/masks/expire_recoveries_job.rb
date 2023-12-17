# frozen_string_literal: true

module Masks
  # Job for deleting recovies requests that passed their expiration time.
  #
  # This job delegates its work to the configured
  # +Masks::Adapter+, specifically calling +#expire_recoveries+.
  #
  # @see Masks::Adapter Masks::Adapter
  class ExpireRecoveriesJob < ApplicationJob
    def perform
      Masks.configuration.expire_recoveries
    end
  end
end
