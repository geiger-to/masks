#/ frozen_string_literal: true

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

    field :actors,
          Types::ActorType.connection_type,
          null: false,
          managers_only: true do
      argument :identifier, String, required: false
    end

    def actors(**args)
      scope = Masks::Actor.order(created_at: :desc)

      if args[:identifier]
        scope =
          scope.joins(:emails).where(
            "masks_emails.address LIKE :email OR nickname LIKE :nickname",
            email: "%#{Masks::Actor.sanitize_sql_like(args[:identifier])}%",
            nickname: "#{Masks::Actor.sanitize_sql_like(args[:identifier])}%",
          )
      end

      scope
    end

    field :client,
          Types::ClientType,
          null: true,
          managers_only: true,
          description: "Fetches a client given its id." do
      argument :id, ID, required: true, description: "id of the client."
    end

    def client(id:)
      Masks::Client.find_by(key: id)
    end

    field :clients,
          Types::ClientType.connection_type,
          null: false,
          managers_only: true do
      argument :name, String, required: false
      argument :actor, String, required: false
      argument :device, String, required: false
    end

    def clients(**args)
      scope = Masks::Client.includes(:actors, :devices).order(created_at: :desc)

      if args[:name]
        scope =
          scope.where(
            "name LIKE ?",
            "#{Masks::Client.sanitize_sql_like(args[:name])}%",
          )
      end

      if args[:actor]
        actor = Masks.identify(args[:actor])
        scope = scope.where(actors: { id: actor.id })
      end

      if args[:device]
        device = Masks::Device.find_by(public_id: args[:device])
        scope = scope.where(devices: { id: device&.id })
      end

      scope
    end

    field :install,
          Types::InstallationType,
          description: "Returns the current installation",
          managers_only: true,
          null: true

    def install
      Masks.installation
    end

    field :device,
          Types::DeviceType,
          null: true,
          managers_only: true,
          description: "Fetches a device given its id." do
      argument :id, ID, required: true, description: "id of the device."
    end

    def device(id:)
      Masks::Device.find_by(public_id: id)
    end

    field :devices,
          Types::DeviceType.connection_type,
          null: false,
          managers_only: true do
      argument :id, String, required: false
      argument :actor, String, required: false
    end

    def devices(**args)
      scope = Masks::Device.includes(:actors, :clients).order(created_at: :desc)

      if args[:id]
        scope =
          scope.where(
            "public_id LIKE ?",
            "#{Masks::Device.sanitize_sql_like(args[:id])}%",
          )
      end

      if args[:actor]
        actor = Masks.identify(args[:actor])
        scope = scope.where(actors: { id: actor.id })
      end

      scope
    end

    field :entries,
          Types::EntryType.connection_type,
          null: false,
          managers_only: true do
      argument :actor, String, required: false, description: "filter by actor"
      argument :client, String, required: false, description: "filter by actor"
      argument :device, String, required: false, description: "filter by device"
    end

    def entries(**args)
      scope =
        Masks::Entry.includes(:actor, :device, :client).order(created_at: :desc)

      if args[:actor]
        actor = Masks.identify(args[:actor])
        scope = scope.where(actor: actor.persisted? ? actor : nil)
      end

      if args[:client]
        scope = scope.where(client: Masks::Client.find_by(key: args[:client]))
      end

      if args[:device]
        scope =
          scope.where(device: Masks::Device.find_by(public_id: args[:device]))
      end

      scope
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
      argument :query,
               String,
               required: true,
               description: "search query to use for filtering data"
    end

    def search(**args)
      query = parse_query(args[:query])

      return unless query.length > 0

      actors = find_actors(query)
      clients = find_clients(query)
      result = { actors:, clients:, query: }
      result
    end

    private

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
      return "" unless query&.present?

      query.strip
    end
  end
end
