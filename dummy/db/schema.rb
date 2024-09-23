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

ActiveRecord::Schema[7.1].define(version: 2024_05_16_004559) do
  create_table "masks_access_tokens", force: :cascade do |t|
    t.string "token"
    t.string "refresh_token"
    t.string "refreshed_token"
    t.text "scopes"
    t.integer "actor_id"
    t.integer "device_id"
    t.integer "client_id"
    t.integer "tenant_id"
    t.datetime "expires_at"
    t.datetime "revoked_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_id"], name: "index_masks_access_tokens_on_actor_id"
    t.index ["client_id"], name: "index_masks_access_tokens_on_client_id"
    t.index ["device_id"], name: "index_masks_access_tokens_on_device_id"
    t.index ["refresh_token"], name: "index_masks_access_tokens_on_refresh_token", unique: true
    t.index ["refreshed_token"], name: "index_masks_access_tokens_on_refreshed_token", unique: true
    t.index ["tenant_id"], name: "index_masks_access_tokens_on_tenant_id"
    t.index ["token"], name: "index_masks_access_tokens_on_token", unique: true
  end

  create_table "masks_actors", force: :cascade do |t|
    t.integer "tenant_id"
    t.string "uuid"
    t.string "type"
    t.string "version"
    t.string "password_digest"
    t.string "totp_secret"
    t.text "backup_codes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "last_login_at"
    t.datetime "changed_password_at"
    t.datetime "added_phone_number_at"
    t.datetime "added_totp_secret_at"
    t.datetime "saved_backup_codes_at"
    t.datetime "notified_inactive_at"
    t.index ["tenant_id"], name: "index_masks_actors_on_tenant_id"
  end

  create_table "masks_authorizations", force: :cascade do |t|
    t.string "code"
    t.string "nonce"
    t.string "redirect_uri"
    t.text "scopes"
    t.integer "actor_id"
    t.integer "device_id"
    t.integer "client_id"
    t.integer "tenant_id"
    t.datetime "expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_id"], name: "index_masks_authorizations_on_actor_id"
    t.index ["client_id"], name: "index_masks_authorizations_on_client_id"
    t.index ["code"], name: "index_masks_authorizations_on_code", unique: true
    t.index ["device_id"], name: "index_masks_authorizations_on_device_id"
    t.index ["tenant_id"], name: "index_masks_authorizations_on_tenant_id"
  end

  create_table "masks_clients", force: :cascade do |t|
    t.string "name"
    t.string "key"
    t.string "secret"
    t.string "client_type"
    t.text "redirect_uris"
    t.text "scopes"
    t.boolean "consent"
    t.string "subject_type"
    t.string "sector_identifier"
    t.string "code_expires_in"
    t.string "id_token_expires_in"
    t.string "access_token_expires_in"
    t.string "refresh_expires_in"
    t.text "rsa_private_key"
    t.integer "tenant_id"
    t.integer "profile_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["profile_id"], name: "index_masks_clients_on_profile_id"
    t.index ["tenant_id", "key"], name: "index_masks_clients_on_tenant_id_and_key", unique: true
    t.index ["tenant_id"], name: "index_masks_clients_on_tenant_id"
  end

  create_table "masks_devices", force: :cascade do |t|
    t.integer "tenant_id"
    t.string "key"
    t.string "user_agent"
    t.string "ip_address"
    t.string "fingerprint"
    t.string "version"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tenant_id", "key"], name: "index_masks_devices_on_tenant_id_and_key", unique: true
    t.index ["tenant_id"], name: "index_masks_devices_on_tenant_id"
  end

  create_table "masks_id_tokens", force: :cascade do |t|
    t.string "nonce"
    t.integer "actor_id"
    t.integer "device_id"
    t.integer "client_id"
    t.integer "tenant_id"
    t.datetime "expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_id"], name: "index_masks_id_tokens_on_actor_id"
    t.index ["client_id"], name: "index_masks_id_tokens_on_client_id"
    t.index ["device_id"], name: "index_masks_id_tokens_on_device_id"
    t.index ["nonce"], name: "index_masks_id_tokens_on_nonce", unique: true
    t.index ["tenant_id"], name: "index_masks_id_tokens_on_tenant_id"
  end

  create_table "masks_identifiers", force: :cascade do |t|
    t.integer "tenant_id"
    t.integer "profile_id"
    t.string "value"
    t.string "type"
    t.integer "actor_id"
    t.datetime "verified_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_id"], name: "index_masks_identifiers_on_actor_id"
    t.index ["profile_id"], name: "index_masks_identifiers_on_profile_id"
    t.index ["tenant_id", "value"], name: "index_masks_identifiers_on_tenant_id_and_value", unique: true
    t.index ["tenant_id"], name: "index_masks_identifiers_on_tenant_id"
  end

  create_table "masks_profiles", force: :cascade do |t|
    t.integer "tenant_id"
    t.string "key"
    t.string "name"
    t.text "settings"
    t.datetime "defaulted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_masks_profiles_on_key", unique: true
    t.index ["tenant_id"], name: "index_masks_profiles_on_tenant_id"
  end

  create_table "masks_rules", force: :cascade do |t|
    t.integer "tenant_id"
    t.integer "masks_profile_id"
    t.string "key"
    t.string "actor"
    t.text "checks"
    t.text "credentials"
    t.text "scopes"
    t.text "request"
    t.text "access"
    t.text "settings"
    t.text "pass", default: "/"
    t.text "fail"
    t.boolean "skip"
    t.boolean "anon"
    t.datetime "enabled_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_masks_rules_on_key", unique: true
    t.index ["masks_profile_id"], name: "index_masks_rules_on_masks_profile_id"
    t.index ["tenant_id"], name: "index_masks_rules_on_tenant_id"
  end

  create_table "masks_scopes", force: :cascade do |t|
    t.integer "tenant_id"
    t.integer "actor_id"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_id"], name: "index_masks_scopes_on_actor_id"
    t.index ["tenant_id", "name", "actor_id"], name: "index_masks_scopes_on_tenant_id_and_name_and_actor_id", unique: true
    t.index ["tenant_id"], name: "index_masks_scopes_on_tenant_id"
  end

  create_table "masks_settings", force: :cascade do |t|
    t.string "name"
    t.text "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_masks_settings_on_name", unique: true
  end

  create_table "masks_tenants", force: :cascade do |t|
    t.string "key"
    t.string "name"
    t.string "version"
    t.text "settings"
    t.integer "client_id"
    t.integer "admin_id"
    t.datetime "seeded_at"
    t.datetime "enabled_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["admin_id"], name: "index_masks_tenants_on_admin_id"
    t.index ["client_id"], name: "index_masks_tenants_on_client_id"
    t.index ["key"], name: "index_masks_tenants_on_key", unique: true
  end

  create_table "sessions", force: :cascade do |t|
    t.string "session_id", null: false
    t.text "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["session_id"], name: "index_sessions_on_session_id", unique: true
    t.index ["updated_at"], name: "index_sessions_on_updated_at"
  end

end
