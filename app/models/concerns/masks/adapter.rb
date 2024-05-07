# frozen_string_literal: true

module Masks
  # An interface that all configuration adapters should adhere to.
  #
  # @see Masks::Adapters::ActiveRecord
  module Adapter
    # Creates a new adapter.
    #
    # @param [Masks::Configuration] config
    # @return [Masks::Adapter]
    def initialize(config)
      @config = config
    end

    # Expires any outdated or invalid actors.
    #
    # @return
    def expire_actors
      raise NotImplementedError
    end
  end
end
