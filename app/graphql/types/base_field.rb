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
      if @managers_only
        context[:auth]
          .prompt_for(Masks::Prompts::InternalSession)
          .current_actor
          &.masks_manager?
      end

      true
    end
  end
end
