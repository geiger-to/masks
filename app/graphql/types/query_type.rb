# frozen_string_literal: true

module Types
  class QueryType < Types::BaseObject
    include GraphQL::Types::Relay::HasNodeField

    PREFIXES = %w[d device devices e event events]

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
      prefix, query = parse_query(query)
      events = %w[e event events].include?(prefix)

      return unless context[:actor]&.masks_manager?
      return unless query.length > 0

      actors = find_actors(query)
      clients = find_clients(query)
      result = { actors:, clients:, prefix:, query: }
      one_of = clients.one? || actors.one?

      if events
        result[:events] = one_of ? Masks::Event.all : Masks::Event.none
        result[:events] = result[:events].where(actor: actors) if one_of &&
          actors.any?
        result[:events] = result[:events].where(client: clients) if one_of &&
          clients.any?
      end

      result
    end

    def find_clients(query)
      return Masks::Client.none if query.start_with?("@")

      Masks::Client.where(
        "key LIKE ? OR name LIKE ?",
        "#{query}%",
        "%#{query}%",
      ).all
    end

    def find_actors(query)
      unless query.start_with?("@") || query.include?("@")
        return Masks::Actor.none
      end

      nickname =
        query.start_with?("@") && !query.include?(".") ? query.slice(1..) : nil

      Masks::Actor.where("nickname LIKE ?", "#{nickname}%").all
    end

    def parse_query(query)
      parts = query.split(" ", 2)

      if parts[0] && parts[1] && PREFIXES.include?(parts[0])
        return parts[0], parts[1]
      else
        return nil, query
      end
    end
  end
end
