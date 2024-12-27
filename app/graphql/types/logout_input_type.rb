# frozen_string_literal: true

module Types
  class LogoutInputType < Types::BaseInputObject
    one_of

    argument :actor, String, required: false
    argument :device, String, required: false
  end
end
