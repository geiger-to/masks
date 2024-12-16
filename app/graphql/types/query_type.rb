# frozen_string_literal: true

module Types
  class QueryType < Types::BaseObject
    field :actor,
          Types::ActorType,
          null: true,
          managers_only: true,
          description: "Fetches an actor given its identifier." do
      argument :identifier,
               String,
               required: false,
               description: "identifier of the actor."
      argument :id, ID, required: false, description: "id of the actor."
    end

    def actor(identifier: nil, id: nil)
      actor =
        if identifier
          Masks.identify(identifier)
        else
          Masks::Actor.find_by(key: id)
        end

      actor if actor&.persisted?
    end

    field :actors, Types::ActorType.connection_type, null: false

    def actors
      Masks::Actor.order(created_at: :desc)
    end

    field :client,
          Types::ClientType,
          null: true,
          managers_only: true,
          description: "Fetches a client given its id." do
      argument :id, String, required: true, description: "id of the client."
    end

    def client(id:)
      Masks::Client.find_by(key: id)
    end

    field :clients, Types::ClientType.connection_type, null: false

    def clients
      Masks::Client.order(created_at: :desc)
    end

    field :install,
          Types::InstallationType,
          description: "Returns the current installation",
          managers_only: true,
          null: true

    def install
      Masks.installation
    end

    field :devices, Types::DeviceType.connection_type, null: false

    def devices
      Masks::Device.order(created_at: :desc)
    end

    field :emails, Types::EmailType.connection_type, null: false

    def emails
      Masks::Email.order(created_at: :desc).includes(:actor)
    end

    field :phones, Types::PhoneType.connection_type, null: false

    def phones
      Masks::Phone.order(created_at: :desc).includes(:actor)
    end

    field :search, Types::SearchType, null: true, managers_only: true do
      argument :jwts, Boolean, required: false
      argument :tokens, Boolean, required: false
      argument :codes, Boolean, required: false
      argument :devices, Boolean, required: false
      argument :query,
               String,
               required: true,
               description: "search query to use for filtering data"
    end

    def search(**args)
      query, connections = parse_query(args[:query])

      return unless query.length > 0

      actors = find_actors(query)
      clients = find_clients(query)
      result = { actors:, clients:, query: }
      one_of = clients.one? || actors.one?

      if one_of
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
        Masks::AccessToken.latest.where(actor: actors)
      elsif clients.any?
        Masks::AccessToken.latest.where(client: clients)
      end
    end

    def connect_codes(actors, clients)
      if actors.any?
        Masks::AuthorizationCode.latest.where(actor: actors)
      elsif clients.any?
        Masks::AuthorizationCode.latest.where(client: clients)
      end
    end

    def connect_jwts(actors, clients)
      if actors.any?
        Masks::IdToken.latest.where(actor: actors)
      elsif clients.any?
        Masks::IdToken.latest.where(client: clients)
      end
    end

    def connect_devices(actors, clients)
      if actors.any?
        (
          Masks::Device
            .latest
            .joins(:actors)
            .where("masks_actors.id" => actors)
            .distinct
        )
      elsif clients.any?
        (
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
