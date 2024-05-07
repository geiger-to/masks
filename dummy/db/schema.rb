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

ActiveRecord::Schema[7.1].define(version: 2024_04_10_194651) do
  create_table "actor_identifiers", force: :cascade do |t|
    t.string "value"
    t.string "type"
    t.integer "actor_id"
    t.datetime "verified_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_id"], name: "index_actor_identifiers_on_actor_id"
    t.index ["value"], name: "index_actor_identifiers_on_value", unique: true
  end

  create_table "actors", force: :cascade do |t|
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
  end

  create_table "devices", force: :cascade do |t|
    t.string "key"
    t.string "user_agent"
    t.string "ip_address"
    t.string "fingerprint"
    t.string "version"
    t.integer "actor_id"
    t.datetime "accessed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_id"], name: "index_devices_on_actor_id"
    t.index ["key", "actor_id"], name: "index_devices_on_key_and_actor_id", unique: true
  end

  create_table "keys", force: :cascade do |t|
    t.string "name"
    t.string "sha"
    t.text "scopes"
    t.integer "actor_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "accessed_at"
    t.index ["actor_id"], name: "index_keys_on_actor_id"
    t.index ["sha"], name: "index_keys_on_sha", unique: true
  end

  create_table "openid_access_tokens", force: :cascade do |t|
    t.string "token"
    t.string "refresh_token"
    t.string "refreshed_token"
    t.text "scopes"
    t.integer "actor_id"
    t.integer "openid_client_id"
    t.datetime "expires_at"
    t.datetime "revoked_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_id"], name: "index_openid_access_tokens_on_actor_id"
    t.index ["openid_client_id"], name: "index_openid_access_tokens_on_openid_client_id"
    t.index ["refresh_token"], name: "index_openid_access_tokens_on_refresh_token", unique: true
    t.index ["refreshed_token"], name: "index_openid_access_tokens_on_refreshed_token", unique: true
    t.index ["token"], name: "index_openid_access_tokens_on_token", unique: true
  end

  create_table "openid_authorizations", force: :cascade do |t|
    t.string "code"
    t.string "nonce"
    t.string "redirect_uri"
    t.text "scopes"
    t.integer "actor_id"
    t.integer "openid_client_id"
    t.datetime "expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_id"], name: "index_openid_authorizations_on_actor_id"
    t.index ["code"], name: "index_openid_authorizations_on_code", unique: true
    t.index ["openid_client_id"], name: "index_openid_authorizations_on_openid_client_id"
  end

  create_table "openid_clients", force: :cascade do |t|
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
    t.string "token_expires_in"
    t.string "refresh_expires_in"
    t.text "rsa_private_key"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_openid_clients_on_key", unique: true
  end

  create_table "openid_id_tokens", force: :cascade do |t|
    t.string "nonce"
    t.datetime "expires_at"
    t.integer "actor_id"
    t.integer "openid_client_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_id"], name: "index_openid_id_tokens_on_actor_id"
    t.index ["openid_client_id"], name: "index_openid_id_tokens_on_openid_client_id"
  end

  create_table "roles", force: :cascade do |t|
    t.string "type"
    t.string "actor_type"
    t.integer "actor_id"
    t.string "record_type"
    t.integer "record_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_type", "actor_id"], name: "index_roles_on_actor"
    t.index ["record_type", "record_id"], name: "index_roles_on_record"
    t.index ["type", "actor_id", "actor_type", "record_id", "record_type"], name: "idx_on_type_actor_id_actor_type_record_id_record_ty_8325f57a0b", unique: true
  end

  create_table "scopes", force: :cascade do |t|
    t.string "name"
    t.string "actor_type"
    t.integer "actor_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_type", "actor_id"], name: "index_scopes_on_actor"
    t.index ["name", "actor_id"], name: "index_scopes_on_name_and_actor_id", unique: true
  end

  create_table "settings", force: :cascade do |t|
    t.string "name"
    t.text "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_settings_on_name", unique: true
  end

end
