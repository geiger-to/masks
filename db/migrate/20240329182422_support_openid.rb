# frozen_string_literal: true
class SupportOpenID < ActiveRecord::Migration[7.1]
  def change
    create_table :openid_clients do |t|
      t.string :name
      t.string :key
      t.string :secret
      t.string :client_type
      t.text :redirect_uris
      t.text :scopes
      t.boolean :consent
      t.string :subject_type
      t.string :sector_identifier
      t.string :code_expires_in
      t.string :token_expires_in
      t.string :refresh_expires_in
      t.text :rsa_private_key

      t.timestamps

      t.index :key, unique: true
    end

    create_table :openid_authorizations do |t|
      t.string :code
      t.string :nonce
      t.string :redirect_uri
      t.text :scopes

      t.references :actor
      t.references :openid_client
      t.datetime :expires_at
      t.timestamps

      t.index :code, unique: true
    end

    create_table :openid_access_tokens do |t|
      t.string :token
      t.string :refresh_token
      t.string :refreshed_token
      t.text :scopes

      t.references :actor, null: true
      t.references :openid_client
      t.datetime :expires_at
      t.datetime :revoked_at
      t.timestamps

      t.index :token, unique: true
      t.index :refresh_token, unique: true
      t.index :refreshed_token, unique: true
    end

    create_table :openid_id_tokens do |t|
      t.string :nonce
      t.datetime :expires_at

      t.references :actor
      t.references :openid_client
      t.timestamps
    end
  end
end
