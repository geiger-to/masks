# frozen_string_literal: true

module Types
  class AuthenticateInputType < Types::BaseInputObject
    argument :id, ID, required: false
    argument :event, String, required: false
    argument :updates, GraphQL::Types::JSON, required: false
    argument :upload, ApolloUploadServer::Upload, required: false
  end
end
