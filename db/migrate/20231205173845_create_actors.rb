# frozen_string_literal: true

class CreateActors < ActiveRecord::Migration[7.1]
  def change
    create_table :masks_tenants do |t|
      t.string :key
      t.string :name
      t.string :version
      t.text :settings

      t.references :client, null: true
      t.references :admin, null: true

      t.datetime :seeded_at
      t.datetime :enabled_at
      t.timestamps

      t.index %i[key], unique: true
    end

    create_table :masks_profiles do |t|
      t.references :tenant

      t.string :key
      t.string :name
      t.text   :settings

      t.datetime :defaulted_at
      t.timestamps

      t.index %i[key], unique: true
    end

    create_table :masks_devices do |t|
      t.references :tenant
      t.string :key
      t.string :user_agent
      t.string :ip_address
      t.string :fingerprint
      t.string :version

      t.timestamps

      t.index %i[tenant_id key], unique: true
    end

    create_table :masks_actors do |t|
      t.references :tenant

      t.string :uuid
      t.string :type
      t.string :version
      t.string :password_digest
      t.string :totp_secret
      t.text :backup_codes

      t.timestamps
      t.datetime :last_login_at
      t.datetime :changed_password_at
      t.datetime :added_phone_number_at
      t.datetime :added_totp_secret_at
      t.datetime :saved_backup_codes_at
      t.datetime :notified_inactive_at
    end

    create_table :masks_identifiers do |t|
      t.references :tenant
      t.references :profile

      t.string :value
      t.string :type
      t.references :actor

      t.datetime :verified_at
      t.timestamps

      t.index [:tenant_id, :value], unique: true
    end


    create_table :masks_scopes do |t|
      t.references :tenant
      t.references :actor
      t.string :name
      t.index %i[tenant_id name actor_id], unique: true
      t.timestamps
    end
  end
end
