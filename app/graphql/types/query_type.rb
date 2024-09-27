# frozen_string_literal: true

module Types
  class QueryType < Types::BaseObject
    include GraphQL::Types::Relay::HasNodeField

    field :node,
          Types::NodeType,
          null: true,
          description: "Fetches an object given its ID." do
      argument :id, ID, required: true, description: "ID of the object."
    end

    def node(id:)
      context.schema.object_from_id(id, context)
    end

    def nodes(ids:)
      ids.map { |id| context.schema.object_from_id(id, context) }
    end

    field :search, Types::SearchType, null: true do
      argument :query,
               String,
               required: true,
               description: "search query to use for filtering data"
    end

    def search(query:)
      return unless context[:actor]&.masks_manager?
      return unless query.length > 0

      { actors: find_actors(query), clients: find_clients(query) }
    end

    def find_clients(query)
      return if query.start_with?("@")

      Masks::Client.where(
        "key LIKE ? OR name LIKE ?",
        "#{query}%",
        "%#{query}%",
      ).all
    end

    def find_actors(query)
      return unless query.start_with?("@") || query.include?("@")

      nickname =
        query.start_with?("@") && !query.include?(".") ? query.slice(1..) : nil

      Masks::Actor.where("nickname LIKE ?", "#{nickname}%").all
    end
  end
end
