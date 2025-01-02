# frozen_string_literal: true

module Types
  class TokenInputType < Types::BaseInputObject
    argument :id, String, required: false
    argument :revoked, Boolean, required: false
  end
end
