# frozen_string_literal: true

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

ActiveRecord::Schema[7.1].define(version: 20_231_205_173_845) do
  create_table 'actors', force: :cascade do |t|
    t.string 'type'
    t.string 'nickname'
    t.string 'version'
    t.string 'password_digest'
    t.string 'phone_number'
    t.string 'totp_secret'
    t.text 'backup_codes'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.datetime 'last_login_at'
    t.datetime 'changed_password_at'
    t.datetime 'added_phone_number_at'
    t.datetime 'added_totp_secret_at'
    t.datetime 'saved_backup_codes_at'
    t.datetime 'notified_inactive_at'
    t.index ['nickname'], name: 'index_actors_on_nickname', unique: true
  end

  create_table 'devices', force: :cascade do |t|
    t.string 'key'
    t.string 'user_agent'
    t.string 'ip_address'
    t.string 'fingerprint'
    t.string 'version'
    t.integer 'actor_id'
    t.datetime 'accessed_at'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['actor_id'], name: 'index_devices_on_actor_id'
    t.index %w[key actor_id], name: 'index_devices_on_key_and_actor_id', unique: true
  end

  create_table 'emails', force: :cascade do |t|
    t.string 'email'
    t.string 'token'
    t.integer 'actor_id'
    t.boolean 'verified'
    t.datetime 'verified_at'
    t.datetime 'notified_at'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['actor_id'], name: 'index_emails_on_actor_id'
    t.index %w[email verified], name: 'index_emails_on_email_and_verified', unique: true
    t.index ['token'], name: 'index_emails_on_token', unique: true
  end

  create_table 'keys', force: :cascade do |t|
    t.string 'name'
    t.string 'sha'
    t.text 'scopes'
    t.integer 'actor_id'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.datetime 'accessed_at'
    t.index ['actor_id'], name: 'index_keys_on_actor_id'
    t.index ['sha'], name: 'index_keys_on_sha', unique: true
  end

  create_table 'recoveries', force: :cascade do |t|
    t.string 'token'
    t.string 'nickname'
    t.string 'email'
    t.string 'phone'
    t.integer 'actor_id'
    t.datetime 'notified_at'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['actor_id'], name: 'index_recoveries_on_actor_id'
    t.index %w[token actor_id], name: 'index_recoveries_on_token_and_actor_id', unique: true
  end

  create_table 'roles', force: :cascade do |t|
    t.string 'type'
    t.string 'actor_type'
    t.integer 'actor_id'
    t.string 'record_type'
    t.integer 'record_id'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index %w[actor_type actor_id], name: 'index_roles_on_actor'
    t.index %w[record_type record_id], name: 'index_roles_on_record'
    t.index %w[type actor_id actor_type record_id record_type],
            name: 'idx_on_type_actor_id_actor_type_record_id_record_ty_8325f57a0b', unique: true
  end

  create_table 'scopes', force: :cascade do |t|
    t.string 'name'
    t.string 'actor_type'
    t.integer 'actor_id'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index %w[actor_type actor_id], name: 'index_scopes_on_actor'
    t.index %w[name actor_id], name: 'index_scopes_on_name_and_actor_id', unique: true
  end
end
