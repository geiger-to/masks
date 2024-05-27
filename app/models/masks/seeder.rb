# frozen_string_literal: true
module Masks
  class Seeder
    def self.run(&)
      ActiveRecord::Base.transaction { new.instance_exec(&) }
    end

    def seed_tenant(key)
      tenant = Masks::Tenant.find_or_initialize_by(key:)
      return if tenant.seeded?
      yield tenant if block_given?
      tenant.seeded_at = Time.current
      puts "saving tenant \"#{tenant.key}\"..."
      tenant.save!
      tenant
    end

    def seed_profile(tenant, key, **settings)
      profile = tenant.profiles.find_or_initialize_by(key:)

      return profile unless profile.new_record?

      profile.settings = settings

      yield profile if block_given?

      puts "saving profile \"#{profile.key}\"..."
      profile.save!
      profile
    end

    def seed_actor(profile, identifier, **attrs)
      id = profile.identifier(value: identifier)
      puts "invalid identifier \"#{identifier}\"" unless id
      actor = profile.find_actor(identifier:)
      actor ||= profile.tenant.actors.build(**attrs)

      return actor unless actor.new_record?

      actor.identifiers << id

      yield actor if block_given?

      puts "saving actor \"#{identifier}\"..."

      actor.save!
      actor
    end

    def seed_client(profile, key, **attrs)
      client = profile.tenant.clients.find_by(key:)
      client ||= profile.tenant.clients.build(key:, profile:, **attrs)

      return client unless client.new_record?

      yield client if block_given?

      puts "saving openid client \"#{key}\"..."

      client.save!
      client
    end
  end
end
