# frozen_string_literal: true

# Top-level module for masks.
module Masks
  class Seeder
    attr_accessor :manage_client, :manager, :tester

    def initialize(env: Rails.env)
      @env = env
    end

    def seed_client(
      key:,
      name:,
      type:,
      redirect_uris: nil,
      consent: true,
      scopes: nil,
      logo: nil
    )
      client =
        Masks::Client.create!(
          key:,
          name:,
          scopes:,
          redirect_uris:,
          consent:,
          client_type: type,
        )

      if logo
        client.logo.attach(io: File.open(Rails.root.join(logo)), filename: logo)
      end
      client
    end

    def seed_actor(nickname:, password: "password", scopes: nil)
      actor = Masks::Actor.new(nickname:)
      actor.password = password
      actor.assign_scopes(*scopes)
      actor.save!
      actor
    end

    def seed_manager(**args)
      manager = seed_actor(**args, nickname: "manager")
      manager.assign_scopes(Masks::Scoped::MANAGE)
      manager.save!
      manager
    end

    def seed_env!
      case @env.to_sym
      when :development, :test
        self.tester = seed_actor(nickname: "test")
        self.manager = seed_manager
        self.manage_client =
          seed_client(
            type: "internal",
            key: Masks::Client::MANAGE_KEY,
            name: "Manage masks",
            scopes: Masks::Scoped::MANAGE,
            redirect_uris: "/manage",
            logo: "app/assets/images/masks.png",
            consent: false,
          )
        seed_client(
          type: "confidential",
          key: "confidential",
          name: "Confidential",
          scopes: "",
          redirect_uris: "http://localhost:1111/test",
          consent: true,
        )
      end
    end
  end
end
