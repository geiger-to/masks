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
      t.datetime :reconfigured_at

      t.timestamps
    end

    create_table :masks_actors do |t|
      t.string :key
      t.string :uuid
      t.string :name, null: true
      t.string :nickname
      t.string :phone_number
      t.string :password_digest
      t.string :totp_secret
      t.string :webauthn_id
      t.string :tz
      t.text :backup_codes
      t.text :scopes

      t.timestamps
      t.datetime :last_login_at
      t.datetime :password_changed_at
      t.datetime :added_phone_number_at
      t.datetime :enabled_second_factor_at
      t.datetime :added_totp_secret_at
      t.datetime :saved_backup_codes_at
      t.datetime :notified_inactive_at
      t.datetime :onboarded_at

      t.index %i[nickname], unique: true
      t.index %i[uuid], unique: true
      t.index %i[key], unique: true
    end

    create_table :masks_addresses do |t|
      t.string :name, null: false
      t.string :address, null: false
      t.string :latitude, null: true
      t.string :longitude, null: true

      t.timestamps

      t.references :actor
    end

    create_table :masks_emails do |t|
      t.string :address, null: false
      t.string :group
      t.datetime :verified_at
      t.timestamps

      t.references :actor

      t.index %i[address group], unique: true
    end

    create_table :masks_phones do |t|
      t.string :number, null: false

      t.timestamps
      t.datetime :verified_at

      t.references :actor

      t.index %i[number], unique: true
    end

    create_table :masks_otp_secrets do |t|
      t.string :public_id, null: false
      t.string :name, null: true
      t.string :secret, null: false

      t.timestamps
      t.datetime :verified_at

      t.references :actor

      t.index :secret, unique: true
      t.index :public_id, unique: true
    end

    create_table :masks_login_links do |t|
      t.string :token
      t.string :code
      t.boolean :log_in, null: false, default: false
      t.text :settings

      t.references :client
      t.references :actor
      t.references :email
      t.references :device

      t.datetime :revoked_at
      t.datetime :expires_at
      t.datetime :authenticated_at
      t.datetime :reset_password_at
      t.timestamps

      t.index %i[code email_id device_id client_id], unique: true
    end

    create_table :masks_hardware_keys do |t|
      t.string :name, null: false
      t.string :aaguid, null: true
      t.string :external_id, null: false
      t.string :public_key, null: false
      t.bigint :sign_count, default: 0, null: false

      t.references :actor
      t.timestamps
      t.datetime :verified_at

      t.index %i[external_id aaguid], unique: true
    end

    create_table :masks_devices do |t|
      t.string :public_id, null: false
      t.string :user_agent
      t.string :ip_address
      t.bigint :version

      t.timestamps
      t.datetime :blocked_at

      t.index %i[public_id], unique: true
    end

    create_table :masks_clients do |t|
      t.string :name
      t.string :key
      t.string :secret
      t.string :client_type
      t.string :public_url, null: true
      t.text :response_types
      t.text :grant_types
      t.text :redirect_uris
      t.text :checks
      t.text :scopes

      t.boolean :allow_passwords
      t.boolean :allow_login_links
      t.boolean :autofill_redirect_uri
      t.boolean :fuzzy_redirect_uri

      t.string :subject_type
      t.string :sector_identifier
      t.string :pairwise_salt
      t.string :id_token_expires_in
      t.string :access_token_expires_in
      t.string :authorization_code_expires_in
      t.string :refresh_token_expires_in
      t.string :client_token_expires_in
      t.string :login_link_expires_in
      t.string :auth_attempt_expires_in
      t.string :login_link_factor_expires_in
      t.string :password_factor_expires_in
      t.string :second_factor_backup_code_expires_in
      t.string :second_factor_phone_expires_in
      t.string :second_factor_totp_code_expires_in
      t.string :second_factor_webauthn_expires_in
      t.string :email_verification_expires_in
      t.string :internal_session_expires_in

      t.text :bg_light
      t.text :bg_dark

      t.text :rsa_private_key

      t.timestamps

      t.index %i[key], unique: true
    end

    create_table :masks_entries do |t|
      t.string :public_id

      t.references :actor
      t.references :device
      t.references :client
      t.timestamps

      t.index :public_id, unique: true
    end

    create_table :masks_tokens do |t|
      t.string :key
      t.string :type
      t.string :secret
      t.string :nonce, null: true
      t.string :redirect_uri, null: true
      t.text :scopes
      t.text :settings

      t.references :client
      t.references :actor, null: true
      t.references :device, null: true
      t.references :entry, null: true
      t.datetime :expires_at
      t.datetime :revoked_at
      t.datetime :refreshed_at
      t.timestamps

      t.index :secret, unique: true
      t.index :key, unique: true
    end
  end
end
