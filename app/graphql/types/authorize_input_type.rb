# frozen_string_literal: true

module Types
  class AuthorizeInputType < Types::BaseInputObject
    argument :id, ID
    argument :scope, [String], required: false
    argument :identifier, String, required: false
    argument :password, String, required: false
    argument :approve, Boolean, required: false
    argument :deny, Boolean, required: false
  end
end
