# frozen_string_literal: true

module Types
  class HardwareKeyInputType < Types::BaseInputObject
    argument :actor_id, ID, required: true
    argument :id, ID, required: true
    argument :action, String, required: true
  end
end