class Init < ActiveRecord::Migration[7.2]
  def change
    create_table :masks_sessions do |t|
      t.string :session_id, null: false
      t.text :data
      t.timestamps
    end

    add_index :masks_sessions, :session_id, unique: true
    add_index :masks_sessions, :updated_at

    create_table :masks_installations do |t|
      t.text :settings
      t.datetime :expired_at

      t.timestamps
    end

    create_table :masks_actors do |t|
      t.string :key
      t.string :nickname
      t.string :password_digest
      t.string :totp_secret
      t.string :version
      t.text :backup_codes
      t.text :scopes

      t.timestamps
      t.datetime :last_login_at
      t.datetime :changed_password_at
      t.datetime :added_totp_secret_at
      t.datetime :saved_backup_codes_at
      t.datetime :notified_inactive_at

      t.index %i[nickname], unique: true
      t.index %i[key], unique: true
    end

    create_table :masks_emails do |t|
      t.string :email, null: false
      t.string :totp
      t.string :group
      t.timestamps

      t.references :actor

      t.index %i[email group], unique: true
    end

    create_table :masks_events do |t|
      t.string :key
      t.text :data

      t.references :actor
      t.references :device
      t.references :client

      t.timestamps
    end

    create_table :masks_devices do |t|
      t.string :session_id, null: false
      t.string :user_agent
      t.string :ip_address
      t.string :version

      t.timestamps

      t.index %i[session_id], unique: true
    end

    create_table :masks_clients do |t|
      t.string :name
      t.string :key
      t.string :secret
      t.string :client_type
      t.text :redirect_uris
      t.text :scopes
      t.boolean :consent
      t.string :subject_type
      t.string :sector_identifier
      t.string :session_expires_in
      t.string :code_expires_in
      t.string :id_token_expires_in
      t.string :access_token_expires_in
      t.string :refresh_expires_in
      t.text :rsa_private_key

      t.timestamps

      t.index %i[key], unique: true
    end

    create_table :masks_authorization_codes do |t|
      t.string :code, limit: 64
      t.string :nonce
      t.string :redirect_uri
      t.text :scopes

      t.references :actor
      t.references :device
      t.references :client
      t.datetime :expires_at
      t.timestamps

      t.index :code, unique: true
    end

    create_table :masks_access_tokens do |t|
      t.string :token, limit: 64
      t.string :refresh_token
      t.string :refreshed_token
      t.text :scopes
      t.text :data

      t.references :client
      t.references :actor, null: true
      t.references :device, null: true
      t.references :authorization_code, null: true
      t.datetime :expires_at
      t.datetime :revoked_at
      t.datetime :refreshed_at
      t.timestamps

      t.index :token, unique: true
      t.index :refresh_token, unique: true
      t.index :refreshed_token, unique: true
    end

    create_table :masks_id_tokens do |t|
      t.string :nonce

      t.references :client
      t.references :actor
      t.references :device
      t.references :authorization_code, null: true

      t.datetime :expires_at
      t.timestamps

      t.index :nonce, unique: true
    end
  end
end
