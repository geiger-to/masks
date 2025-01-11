# frozen_string_literal: true

module Types
  class ClientInputType < Types::BaseInputObject
    argument :id, ID, required: false
    argument :name, String, required: false
    argument :secret, String, required: false
    argument :type, String, required: false
    argument :redirect_uris, String, required: false
    argument :scopes, GraphQL::Types::JSON, required: false
    argument :checks, [String], required: false

    Masks::Client.settings.each do |col, type|
      argument col, type, required: false
    end
  end
end
