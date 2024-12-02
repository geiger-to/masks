# frozen_string_literal: true

module Types
  class BaseField < GraphQL::Schema::Field
    argument_class Types::BaseArgument

    # Override #initialize to take a new argument:
    def initialize(*args, managers_only: nil, **kwargs, &block)
      @managers_only = managers_only

      # Pass on the default args:
      super(*args, **kwargs, &block)
    end

    def visible?(context)
      return MasksSchema.manager?(context) if @managers_only

      true
    end
  end
end
