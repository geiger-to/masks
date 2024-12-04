# frozen_string_literal: true

# Top-level module for masks.
module Masks
  class Seeder
    attr_accessor :manage_client, :manager, :tester, :install

    def initialize(install)
      @install = install
    end

    def seed_attached(object, attachment, path)
      object.try(attachment).attach(
        io: File.open(Rails.root.join(path)),
        filename: path,
      )
    end

    def seed_client(key:, name:, type:, logo: nil, **attrs)
      client = Masks::Client.create!(key:, name:, client_type: type, **attrs)

      seed_attached(client, :logo, logo) if logo

      client
    end

    def seed_actor(nickname:, password:, scopes: nil, email: nil)
      actor = Masks::Actor.new(nickname:)
      if email
        actor.emails.build(address: email, group: Masks::Email::LOGIN_GROUP)
      end
      actor.password = password
      actor.assign_scopes(*scopes)
      actor.save!
      actor
    end

    def seed_manager(**args)
      manager =
        seed_actor(
          **args,
          nickname: install.env.manager.nickname,
          password: install.env.manager.password,
          email: install.env.manager.email,
        )
      manager.assign_scopes(Masks::Scoped::MANAGE)
      manager.save!
      manager
    end

    def seed_env!
      self.manager = seed_manager if install.manager?
      self.manage_client =
        seed_client(
          type: "internal",
          key: Masks::Client::MANAGE_KEY,
          name: "Manage masks",
          scopes: {
            required: [Masks::Scoped::MANAGE],
          },
          redirect_uris: "/manage\n/manage*",
          fuzzy_redirect_uri: true,
        )

      seed_attached(install, :light_logo, "app/assets/images/masks.png")
      seed_attached(install, :dark_logo, "app/assets/images/masks.png")
      seed_attached(install, :favicon, "app/assets/images/masks.png")

      case Rails.env.to_sym
      when :development, :test
        self.tester =
          seed_actor(
            nickname: "tester",
            password: "password",
            email: "test@example.com",
          )
        seed_client(
          type: "confidential",
          key: "confidential",
          name: "Confidential",
          redirect_uris: "http://localhost:1111/test",
          checks: %w[device credentials client-consent],
        )
        seed_client(
          type: "public",
          key: "public",
          name: "Public",
          redirect_uris: "http://localhost:1111/test",
          checks: %w[device credentials client-consent],
        )
      end
    end
  end
end
