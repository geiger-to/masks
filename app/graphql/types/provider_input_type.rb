# frozen_string_literal: true

module Types
  class ProviderInputType < Types::BaseInputObject
    argument :id, String, required: false
    argument :name, String, required: false
    argument :type, String, required: false
    argument :common, Boolean, required: false
    argument :disabled, Boolean, required: false
    argument :enabled, Boolean, required: false
    argument :settings, CamelizedJSON, required: false
  end
end
