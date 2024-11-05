# frozen_string_literal: true

module Types
  class AuthorizeInputType < Types::BaseInputObject
    argument :id, ID
    argument :scope, [String], required: false
    argument :identifier, String, required: false
    argument :password, String, required: false
    argument :updates, GraphQL::Types::JSON, required: false
    argument :event, String, required: false
    argument :upload, ApolloUploadServer::Upload, required: false
  end
end
