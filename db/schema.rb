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

ActiveRecord::Schema[7.2].define(version: 2024_09_23_234426) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "good_job_batches",
               id: :uuid,
               default: -> { "gen_random_uuid()" },
               force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "description"
    t.jsonb "serialized_properties"
    t.text "on_finish"
    t.text "on_success"
    t.text "on_discard"
    t.text "callback_queue_name"
    t.integer "callback_priority"
    t.datetime "enqueued_at"
    t.datetime "discarded_at"
    t.datetime "finished_at"
    t.datetime "jobs_finished_at"
  end

  create_table "good_job_executions",
               id: :uuid,
               default: -> { "gen_random_uuid()" },
               force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "active_job_id", null: false
    t.text "job_class"
    t.text "queue_name"
    t.jsonb "serialized_params"
    t.datetime "scheduled_at"
    t.datetime "finished_at"
    t.text "error"
    t.integer "error_event", limit: 2
    t.text "error_backtrace", array: true
    t.uuid "process_id"
    t.interval "duration"
    t.index %w[active_job_id created_at],
            name: "index_good_job_executions_on_active_job_id_and_created_at"
    t.index %w[process_id created_at],
            name: "index_good_job_executions_on_process_id_and_created_at"
  end

  create_table "good_job_processes",
               id: :uuid,
               default: -> { "gen_random_uuid()" },
               force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "state"
    t.integer "lock_type", limit: 2
  end

  create_table "good_job_settings",
               id: :uuid,
               default: -> { "gen_random_uuid()" },
               force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "key"
    t.jsonb "value"
    t.index ["key"], name: "index_good_job_settings_on_key", unique: true
  end

  create_table "good_jobs",
               id: :uuid,
               default: -> { "gen_random_uuid()" },
               force: :cascade do |t|
    t.text "queue_name"
    t.integer "priority"
    t.jsonb "serialized_params"
    t.datetime "scheduled_at"
    t.datetime "performed_at"
    t.datetime "finished_at"
    t.text "error"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "active_job_id"
    t.text "concurrency_key"
    t.text "cron_key"
    t.uuid "retried_good_job_id"
    t.datetime "cron_at"
    t.uuid "batch_id"
    t.uuid "batch_callback_id"
    t.boolean "is_discrete"
    t.integer "executions_count"
    t.text "job_class"
    t.integer "error_event", limit: 2
    t.text "labels", array: true
    t.uuid "locked_by_id"
    t.datetime "locked_at"
    t.index %w[active_job_id created_at],
            name: "index_good_jobs_on_active_job_id_and_created_at"
    t.index ["batch_callback_id"],
            name: "index_good_jobs_on_batch_callback_id",
            where: "(batch_callback_id IS NOT NULL)"
    t.index ["batch_id"],
            name: "index_good_jobs_on_batch_id",
            where: "(batch_id IS NOT NULL)"
    t.index ["concurrency_key"],
            name: "index_good_jobs_on_concurrency_key_when_unfinished",
            where: "(finished_at IS NULL)"
    t.index %w[cron_key created_at],
            name: "index_good_jobs_on_cron_key_and_created_at_cond",
            where: "(cron_key IS NOT NULL)"
    t.index %w[cron_key cron_at],
            name: "index_good_jobs_on_cron_key_and_cron_at_cond",
            unique: true,
            where: "(cron_key IS NOT NULL)"
    t.index ["finished_at"],
            name: "index_good_jobs_jobs_on_finished_at",
            where:
              "((retried_good_job_id IS NULL) AND (finished_at IS NOT NULL))"
    t.index ["labels"],
            name: "index_good_jobs_on_labels",
            where: "(labels IS NOT NULL)",
            using: :gin
    t.index ["locked_by_id"],
            name: "index_good_jobs_on_locked_by_id",
            where: "(locked_by_id IS NOT NULL)"
    t.index %w[priority created_at],
            name: "index_good_job_jobs_for_candidate_lookup",
            where: "(finished_at IS NULL)"
    t.index %w[priority created_at],
            name: "index_good_jobs_jobs_on_priority_created_at_when_unfinished",
            order: {
              priority: "DESC NULLS LAST",
            },
            where: "(finished_at IS NULL)"
    t.index %w[priority scheduled_at],
            name:
              "index_good_jobs_on_priority_scheduled_at_unfinished_unlocked",
            where: "((finished_at IS NULL) AND (locked_by_id IS NULL))"
    t.index %w[queue_name scheduled_at],
            name: "index_good_jobs_on_queue_name_and_scheduled_at",
            where: "(finished_at IS NULL)"
    t.index ["scheduled_at"],
            name: "index_good_jobs_on_scheduled_at",
            where: "(finished_at IS NULL)"
  end

  create_table "masks_access_tokens", force: :cascade do |t|
    t.string "token"
    t.string "refresh_token"
    t.string "refreshed_token"
    t.text "scopes"
    t.text "data"
    t.bigint "actor_id"
    t.bigint "device_id"
    t.bigint "client_id"
    t.datetime "expires_at"
    t.datetime "revoked_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_id"], name: "index_masks_access_tokens_on_actor_id"
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
    t.string "nickname"
    t.string "password_digest"
    t.string "totp_secret"
    t.string "version"
    t.text "backup_codes"
    t.text "scopes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "last_login_at"
    t.datetime "changed_password_at"
    t.datetime "added_totp_secret_at"
    t.datetime "saved_backup_codes_at"
    t.datetime "notified_inactive_at"
    t.index ["key"], name: "index_masks_actors_on_key", unique: true
    t.index ["nickname"], name: "index_masks_actors_on_nickname", unique: true
  end

  create_table "masks_authorizations", force: :cascade do |t|
    t.string "code"
    t.string "nonce"
    t.string "redirect_uri"
    t.text "scopes"
    t.bigint "actor_id"
    t.bigint "device_id"
    t.bigint "client_id"
    t.datetime "expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_id"], name: "index_masks_authorizations_on_actor_id"
    t.index ["client_id"], name: "index_masks_authorizations_on_client_id"
    t.index ["code"], name: "index_masks_authorizations_on_code", unique: true
    t.index ["device_id"], name: "index_masks_authorizations_on_device_id"
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
    t.string "session_expires_in"
    t.string "code_expires_in"
    t.string "id_token_expires_in"
    t.string "access_token_expires_in"
    t.string "refresh_expires_in"
    t.text "rsa_private_key"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_masks_clients_on_key", unique: true
  end

  create_table "masks_devices", force: :cascade do |t|
    t.string "session_id", null: false
    t.string "user_agent"
    t.string "ip_address"
    t.string "version"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["session_id"],
            name: "index_masks_devices_on_session_id",
            unique: true
  end

  create_table "masks_events", force: :cascade do |t|
    t.string "key"
    t.text "data"
    t.bigint "actor_id"
    t.bigint "device_id"
    t.bigint "client_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_id"], name: "index_masks_events_on_actor_id"
    t.index ["client_id"], name: "index_masks_events_on_client_id"
    t.index ["device_id"], name: "index_masks_events_on_device_id"
  end

  create_table "masks_id_tokens", force: :cascade do |t|
    t.string "nonce"
    t.bigint "actor_id"
    t.bigint "device_id"
    t.bigint "client_id"
    t.datetime "expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_id"], name: "index_masks_id_tokens_on_actor_id"
    t.index ["client_id"], name: "index_masks_id_tokens_on_client_id"
    t.index ["device_id"], name: "index_masks_id_tokens_on_device_id"
    t.index ["nonce"], name: "index_masks_id_tokens_on_nonce", unique: true
  end

  create_table "masks_installation", force: :cascade do |t|
    t.text "settings"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "expired_at"
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

  create_table "sessions", force: :cascade do |t|
    t.string "session_id", null: false
    t.text "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["session_id"], name: "index_sessions_on_session_id", unique: true
    t.index ["updated_at"], name: "index_sessions_on_updated_at"
  end
end