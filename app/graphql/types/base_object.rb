# frozen_string_literal: true

module Types
  class BaseObject < GraphQL::Schema::Object
    include Rails.application.routes.url_helpers

    edge_type_class(Types::BaseEdge)
    connection_type_class(Types::BaseConnection)
    field_class Types::BaseField

    class << self
      def bool(name, null: true, prefix: nil)
        method = prefix ? "#{prefix}_#{name}" : name

        field(method, GraphQL::Types::Boolean, null: null)

        define_method method do
          object.send("#{name}?")
        end
      end
    end
  end
end
