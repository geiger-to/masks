# frozen_string_literal: true

module Types
  class BaseObject < GraphQL::Schema::Object
    include Rails.application.routes.url_helpers

    edge_type_class(Types::BaseEdge)
    connection_type_class(Types::BaseConnection)
    field_class Types::BaseField
  end
end
