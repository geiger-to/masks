# frozen_string_literal: true

module Types
  class EmailInputType < Types::BaseInputObject
    argument :actor_id, String, required: true
    argument :address, String, required: true
    argument :action, String, required: true
  end
end
