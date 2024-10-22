# frozen_string_literal: true

module Types
  class SettingInputType < Types::BaseInputObject
    argument :settings, GraphQL::Types::JSON, required: false
  end
end
