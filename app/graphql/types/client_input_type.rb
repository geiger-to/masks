# frozen_string_literal: true

module Types
  class ClientInputType < Types::BaseInputObject
    argument :id, ID, required: false
    argument :name, String, required: false
    argument :type, String, required: false
    argument :rotate_secret, Boolean, required: false
    argument :redirect_uris, String, required: false
    argument :scopes, String, required: false
  end
end
