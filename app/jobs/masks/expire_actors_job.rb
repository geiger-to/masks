# frozen_string_literal: true

module Masks
  # Job for deleting actors that have passed their expiration time.
  #
  # This job effectively delegates its work to the configured
  # +Masks::Adapter+, specifically calling +#expire_actors+.
  #
  # @see Masks::Adapter Masks::Adapter
  class ExpireActorsJob < ApplicationJob
    def perform
      Masks.configuration.expire_actors
    end
  end
end
