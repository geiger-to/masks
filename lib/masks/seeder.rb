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
      redirect_uris: [],
      consent: true,
      scopes: []
    )
      Masks::Client.create!(
        key:,
        name:,
        scopes:,
        redirect_uris:,
        consent:,
        client_type: type,
      )
    end

    def seed_actor(nickname: "manager", password: "password", scopes: [])
      actor = Masks::Actor.new(nickname:)
      actor.password = password
      actor.assign_scopes(*scopes)
      actor.save!
      actor
    end

    def seed_manager(**args)
      manager = seed_actor(**args)
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
            name: "manage masks",
            scopes: [Masks::Scoped::MANAGE],
            redirect_uris: [Masks.url + "/manage"],
            consent: false,
          )
      end
    end
  end
end
