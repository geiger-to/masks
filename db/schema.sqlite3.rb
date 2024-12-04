# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2024_12_05_155027) do
  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index %w[record_type record_id name blob_id],
            name: "index_active_storage_attachments_uniqueness",
            unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index %w[blob_id variation_digest],
            name: "index_active_storage_variant_records_uniqueness",
            unique: true
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index %w[priority run_at], name: "delayed_jobs_priority"
  end

  create_table "masks_access_tokens", force: :cascade do |t|
    t.string "token", limit: 64
    t.string "refresh_token"
    t.string "refreshed_token"
    t.text "scopes"
    t.text "data"
    t.integer "client_id"
    t.integer "actor_id"
    t.integer "device_id"
    t.integer "authorization_code_id"
    t.datetime "expires_at"
    t.datetime "revoked_at"
    t.datetime "refreshed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_id"], name: "index_masks_access_tokens_on_actor_id"
    t.index ["authorization_code_id"],
            name: "index_masks_access_tokens_on_authorization_code_id"
    t.index ["client_id"], name: "index_masks_access_tokens_on_client_id"
    t.index ["device_id"], name: "index_masks_access_tokens_on_device_id"
    t.index ["refresh_token"],
            name: "index_masks_access_tokens_on_refresh_token",
            unique: true
    t.index ["refreshed_token"],
            name: "index_masks_access_tokens_on_refreshed_token",
            unique: true
    t.index ["token"], name: "index_masks_access_tokens_on_token", unique: true
  end

  create_table "masks_actors", force: :cascade do |t|
    t.string "key"
    t.string "name"
    t.string "nickname"
    t.string "phone_number"
    t.string "password_digest"
    t.string "totp_secret"
    t.string "version"
    t.string "webauthn_id"
    t.string "tz"
    t.text "backup_codes"
    t.text "scopes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "last_login_at"
    t.datetime "password_changed_at"
    t.datetime "added_phone_number_at"
    t.datetime "enabled_second_factor_at"
    t.datetime "added_totp_secret_at"
    t.datetime "saved_backup_codes_at"
    t.datetime "notified_inactive_at"
    t.datetime "onboarded_at"
    t.index ["key"], name: "index_masks_actors_on_key", unique: true
    t.index ["nickname"], name: "index_masks_actors_on_nickname", unique: true
  end

  create_table "masks_addresses", force: :cascade do |t|
    t.string "name", null: false
    t.string "address", null: false
    t.string "latitude"
    t.string "longitude"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "actor_id"
    t.index ["actor_id"], name: "index_masks_addresses_on_actor_id"
  end

  create_table "masks_authorization_codes", force: :cascade do |t|
    t.string "code", limit: 64
    t.string "nonce"
    t.string "redirect_uri"
    t.text "scopes"
    t.integer "actor_id"
    t.integer "device_id"
    t.integer "client_id"
    t.datetime "expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_id"], name: "index_masks_authorization_codes_on_actor_id"
    t.index ["client_id"], name: "index_masks_authorization_codes_on_client_id"
    t.index ["code"],
            name: "index_masks_authorization_codes_on_code",
            unique: true
    t.index ["device_id"], name: "index_masks_authorization_codes_on_device_id"
  end

  create_table "masks_clients", force: :cascade do |t|
    t.string "name"
    t.string "key"
    t.string "secret"
    t.string "client_type"
    t.string "public_url"
    t.string "version"
    t.text "redirect_uris"
    t.text "checks"
    t.text "scopes"
    t.boolean "allow_passwords"
    t.boolean "allow_login_links"
    t.boolean "autofill_redirect_uri"
    t.boolean "fuzzy_redirect_uri"
    t.string "subject_type"
    t.string "sector_identifier"
    t.string "pairwise_salt"
    t.string "code_expires_in"
    t.string "id_token_expires_in"
    t.string "access_token_expires_in"
    t.string "refresh_expires_in"
    t.string "login_link_expires_in"
    t.string "auth_attempt_expires_in"
    t.string "login_link_factor_expires_in"
    t.string "password_factor_expires_in"
    t.string "second_factor_backup_code_expires_in"
    t.string "second_factor_sms_code_expires_in"
    t.string "second_factor_totp_code_expires_in"
    t.string "second_factor_webauthn_expires_in"
    t.string "email_verification_expires_in"
    t.string "internal_session_expires_in"
    t.text "bg_light"
    t.text "bg_dark"
    t.text "rsa_private_key"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_masks_clients_on_key", unique: true
  end

  create_table "masks_devices", force: :cascade do |t|
    t.string "public_id", null: false
    t.string "user_agent"
    t.string "ip_address"
    t.string "version"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "blocked_at"
    t.index ["public_id"],
            name: "index_masks_devices_on_public_id",
            unique: true
  end

  create_table "masks_emails", force: :cascade do |t|
    t.string "address", null: false
    t.string "group"
    t.datetime "verified_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "actor_id"
    t.index ["actor_id"], name: "index_masks_emails_on_actor_id"
    t.index %w[address group],
            name: "index_masks_emails_on_address_and_group",
            unique: true
  end

  create_table "masks_id_tokens", force: :cascade do |t|
    t.string "nonce"
    t.integer "client_id"
    t.integer "actor_id"
    t.integer "device_id"
    t.integer "authorization_code_id"
    t.datetime "expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_id"], name: "index_masks_id_tokens_on_actor_id"
    t.index ["authorization_code_id"],
            name: "index_masks_id_tokens_on_authorization_code_id"
    t.index ["client_id"], name: "index_masks_id_tokens_on_client_id"
    t.index ["device_id"], name: "index_masks_id_tokens_on_device_id"
    t.index ["nonce"], name: "index_masks_id_tokens_on_nonce", unique: true
  end

  create_table "masks_installations", force: :cascade do |t|
    t.text "settings"
    t.datetime "expired_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "masks_login_links", force: :cascade do |t|
    t.string "token"
    t.string "code"
    t.boolean "log_in", default: false, null: false
    t.text "settings"
    t.integer "client_id"
    t.integer "actor_id"
    t.integer "email_id"
    t.integer "device_id"
    t.datetime "revoked_at"
    t.datetime "expires_at"
    t.datetime "authenticated_at"
    t.datetime "reset_password_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_id"], name: "index_masks_login_links_on_actor_id"
    t.index ["client_id"], name: "index_masks_login_links_on_client_id"
    t.index %w[code email_id device_id client_id],
            name: "idx_on_code_email_id_device_id_client_id_2f61fce223",
            unique: true
    t.index ["device_id"], name: "index_masks_login_links_on_device_id"
    t.index ["email_id"], name: "index_masks_login_links_on_email_id"
  end

  create_table "masks_otp_secrets", force: :cascade do |t|
    t.string "public_id", null: false
    t.string "name"
    t.string "secret", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "verified_at"
    t.integer "actor_id"
    t.index ["actor_id"], name: "index_masks_otp_secrets_on_actor_id"
    t.index ["public_id"],
            name: "index_masks_otp_secrets_on_public_id",
            unique: true
    t.index ["secret"], name: "index_masks_otp_secrets_on_secret", unique: true
  end

  create_table "masks_phones", force: :cascade do |t|
    t.string "number", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "verified_at"
    t.integer "actor_id"
    t.index ["actor_id"], name: "index_masks_phones_on_actor_id"
    t.index ["number"], name: "index_masks_phones_on_number", unique: true
  end

  create_table "masks_sessions", force: :cascade do |t|
    t.string "session_id", null: false
    t.text "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["session_id"],
            name: "index_masks_sessions_on_session_id",
            unique: true
    t.index ["updated_at"], name: "index_masks_sessions_on_updated_at"
  end

  create_table "masks_webauthn_credentials", force: :cascade do |t|
    t.string "name", null: false
    t.string "aaguid"
    t.string "external_id", null: false
    t.string "public_key", null: false
    t.bigint "sign_count", default: 0, null: false
    t.integer "actor_id"
    t.integer "device_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "verified_at"
    t.index ["actor_id"], name: "index_masks_webauthn_credentials_on_actor_id"
    t.index ["device_id"], name: "index_masks_webauthn_credentials_on_device_id"
    t.index %w[external_id aaguid],
            name: "index_masks_webauthn_credentials_on_external_id_and_aaguid",
            unique: true
  end

  add_foreign_key "active_storage_attachments",
                  "active_storage_blobs",
                  column: "blob_id"
  add_foreign_key "active_storage_variant_records",
                  "active_storage_blobs",
                  column: "blob_id"
end
