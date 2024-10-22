# frozen_string_literal: true

module Mutations
  class Setting < BaseMutation
    input_object_class Types::SettingInputType

    field :settings, GraphQL::Types::JSON, null: false
    field :errors, [String], null: true

    def visible?(context)
      context[:authorization]&.masks_manager?
    end

    def resolve(**args)
      { settings: Masks.installation.settings }
    end
  end
end
