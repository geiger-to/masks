# frozen_string_literal: true

class CreateActors < ActiveRecord::Migration[7.1]
  def change
    create_table :actors do |t|
      t.string :type
      t.string :nickname
      t.string :version
      t.string :password_digest
      t.string :phone_number
      t.string :totp_secret
      t.text :backup_codes

      t.timestamps
      t.datetime :last_login_at
      t.datetime :changed_password_at
      t.datetime :added_phone_number_at
      t.datetime :added_totp_secret_at
      t.datetime :saved_backup_codes_at
      t.datetime :notified_inactive_at

      t.index :nickname, unique: true
    end

    create_table :scopes do |t|
      t.string :name
      t.references :actor, polymorphic: true
      t.index %i[name actor_id], unique: true
      t.timestamps
    end

    create_table :roles do |t|
      t.string :type
      t.references :actor, polymorphic: true
      t.references :record, polymorphic: true
      t.timestamps
    end

    add_index :roles,
              %i[type actor_id actor_type record_id record_type],
              unique: true

    create_table :emails do |t|
      t.string :email
      t.string :token
      t.references :actor
      t.boolean :verified, null: true
      t.datetime :verified_at
      t.datetime :notified_at
      t.timestamps

      t.index %i[email verified], unique: true
      t.index %i[token], unique: true
    end

    create_table :recoveries do |t|
      t.string :token
      t.string :nickname, null: true
      t.string :email, null: true
      t.string :phone, null: true
      t.references :actor
      t.datetime :notified_at
      t.timestamps

      t.index %i[token actor_id], unique: true
    end

    create_table :devices do |t|
      t.string :key
      t.string :user_agent
      t.string :ip_address
      t.string :fingerprint
      t.string :version

      t.references :actor
      t.datetime :accessed_at
      t.timestamps

      t.index %i[key actor_id], unique: true
    end

    create_table :keys do |t|
      t.string :name
      t.string :sha
      t.text :scopes

      t.references :actor
      t.timestamps
      t.datetime :accessed_at

      t.index %i[sha], unique: true
    end
  end
end
