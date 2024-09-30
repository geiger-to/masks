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
      argument :jwts, Boolean, required: false
      argument :tokens, Boolean, required: false
      argument :codes, Boolean, required: false
      argument :events, Boolean, required: false
      argument :devices, Boolean, required: false
      argument :query,
               String,
               required: true,
               description: "search query to use for filtering data"
    end

    def search(**args)
      query, connections = parse_query(args[:query])

      return unless context[:authorization]&.masks_manager?
      return unless query.length > 0

      actors = find_actors(query)
      clients = find_clients(query)
      result = { actors:, clients:, query: }
      one_of = clients.one? || actors.one?

      if one_of
        if connections.include?("events") || args[:events]
          result[:events] = connect_events(actors, clients)
        end

        if connections.include?("tokens") || args[:tokens]
          result[:tokens] = connect_tokens(actors, clients)
        end

        if connections.include?("codes") || args[:codes]
          result[:codes] = connect_codes(actors, clients)
        end

        if connections.include?("devices") || args[:devices]
          result[:devices] = connect_devices(actors, clients)
        end

        if connections.include?("jwts") || args[:jwts]
          result[:jwts] = connect_jwts(actors, clients)
        end
      end

      result
    end

    private

    def connect_tokens(actors, clients)
      if actors.any?
        return Masks::AccessToken.latest.where(actor: actors)
      elsif clients.any?
        return Masks::AccessToken.latest.where(client: clients)
      end
    end

    def connect_codes(actors, clients)
      if actors.any?
        return Masks::AuthorizationCode.latest.where(actor: actors)
      elsif clients.any?
        return Masks::AuthorizationCode.latest.where(client: clients)
      end
    end

    def connect_events(actors, clients)
      if actors.any?
        return Masks::Event.latest.where(actor: actors)
      elsif clients.any?
        return Masks::Event.latest.where(client: clients)
      end
    end

    def connect_jwts(actors, clients)
      if actors.any?
        return Masks::IdToken.latest.where(actor: actors)
      elsif clients.any?
        return Masks::IdToken.latest.where(client: clients)
      end
    end

    def connect_devices(actors, clients)
      if actors.any?
        return(
          Masks::Device
            .latest
            .joins(:actors)
            .where("masks_actors.id" => actors)
            .distinct
        )
      elsif clients.any?
        return(
          Masks::Device
            .latest
            .joins(:clients)
            .where("masks_clients.id" => clients)
            .distinct
        )
      end
    end

    def find_clients(query)
      return Masks::Client.none if !query || query.start_with?("@")

      Masks::Client.where(
        "key LIKE ? OR name LIKE ?",
        "#{query}%",
        "%#{query}%",
      ).all
    end

    def find_actors(query)
      if !query || (!query.start_with?("@") && !query.include?("@"))
        return Masks::Actor.none
      end

      nickname =
        query.start_with?("@") && !query.include?(".") ? query.slice(1..) : nil

      Masks::Actor.where("nickname LIKE ?", "#{nickname}%").all
    end

    def parse_query(query)
      return query unless query&.present?

      parts = query.split(" ").compact
      added = []

      if parts.last.start_with?("+")
        added = parts.last.split("+").map(&:presence).compact
        parts = parts.slice(0..-2)
      end

      return parts.join(" "), added
    end
  end
end
