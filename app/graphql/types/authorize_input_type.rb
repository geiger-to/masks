# frozen_string_literal: true

module Types
  class AuthorizeInputType < Types::BaseInputObject
    argument :client_id, ID
    argument :redirect_uri, String, required: false
    argument :nickname, String, required: false
    argument :password, String, required: false
  end
end
