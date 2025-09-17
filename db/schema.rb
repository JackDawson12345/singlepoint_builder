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

ActiveRecord::Schema[8.0].define(version: 2025_09_17_135032) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
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
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "components", force: :cascade do |t|
    t.string "name"
    t.string "component_type"
    t.boolean "global"
    t.json "content"
    t.json "editable_fields"
    t.json "field_types"
    t.json "template_patterns"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "login_activities", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "ip_address"
    t.text "user_agent"
    t.string "location"
    t.string "device"
    t.string "browser"
    t.datetime "login_at"
    t.string "city"
    t.string "country"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_login_activities_on_user_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.text "message"
    t.boolean "read"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "notification_type"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "solid_queue_blocked_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.string "queue_name", null: false
    t.integer "priority", default: 0
    t.datetime "expires_at", null: false
    t.datetime "created_at", null: false
    t.index ["expires_at", "priority"], name: "idx_on_expires_at_priority_e4efd7566c"
    t.index ["job_id"], name: "index_solid_queue_blocked_executions_on_job_id"
  end

  create_table "solid_queue_claimed_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.bigint "process_id"
    t.string "queue_name", null: false
    t.integer "priority", default: 0
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_claimed_executions_on_job_id"
    t.index ["process_id", "queue_name"], name: "idx_on_process_id_queue_name_09b5bd9b00"
  end

  create_table "solid_queue_failed_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.text "error"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["job_id"], name: "index_solid_queue_failed_executions_on_job_id"
  end

  create_table "solid_queue_jobs", force: :cascade do |t|
    t.string "queue_name", null: false
    t.string "class_name", null: false
    t.text "arguments"
    t.integer "priority", default: 0
    t.string "active_job_id"
    t.datetime "scheduled_at"
    t.datetime "finished_at"
    t.string "finished_successfully"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "concurrency_key"
    t.index ["active_job_id"], name: "index_solid_queue_jobs_on_active_job_id", unique: true
    t.index ["concurrency_key", "queue_name"], name: "index_solid_queue_jobs_on_concurrency_key_and_queue_name"
    t.index ["queue_name", "finished_at"], name: "index_solid_queue_jobs_on_queue_name_and_finished_at"
    t.index ["scheduled_at"], name: "index_solid_queue_jobs_on_scheduled_at"
  end

  create_table "solid_queue_paused_queues", force: :cascade do |t|
    t.string "queue_name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["queue_name"], name: "index_solid_queue_paused_queues_on_queue_name", unique: true
  end

  create_table "solid_queue_processes", force: :cascade do |t|
    t.string "kind", null: false
    t.datetime "last_heartbeat_at", null: false
    t.bigint "supervisor_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["last_heartbeat_at"], name: "index_solid_queue_processes_on_last_heartbeat_at"
    t.index ["supervisor_id"], name: "index_solid_queue_processes_on_supervisor_id"
  end

  create_table "solid_queue_ready_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.string "queue_name", null: false
    t.integer "priority", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["job_id"], name: "index_solid_queue_ready_executions_on_job_id"
    t.index ["priority", "job_id"], name: "index_solid_queue_ready_executions_on_priority_and_job_id"
  end

  create_table "solid_queue_scheduled_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.string "queue_name", null: false
    t.integer "priority", default: 0
    t.datetime "scheduled_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["job_id"], name: "index_solid_queue_scheduled_executions_on_job_id"
    t.index ["scheduled_at", "priority"], name: "idx_on_scheduled_at_priority_85695a030a"
  end

  create_table "solid_queue_semaphores", force: :cascade do |t|
    t.string "key", null: false
    t.integer "value", default: 1
    t.datetime "expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["expires_at"], name: "index_solid_queue_semaphores_on_expires_at"
    t.index ["key"], name: "index_solid_queue_semaphores_on_key", unique: true
  end

  create_table "themes", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.json "pages"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.json "settings"
    t.text "global_css"
  end

  create_table "user_connections", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "provider", null: false
    t.string "uid", null: false
    t.string "name"
    t.string "email"
    t.string "image"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["provider", "uid"], name: "index_user_connections_on_provider_and_uid", unique: true
    t.index ["user_id"], name: "index_user_connections_on_user_id"
  end

  create_table "user_setups", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "domain_name"
    t.string "package_type"
    t.string "support_option"
    t.string "payment_status"
    t.string "stripe_payment_intent_id"
    t.string "paid_at"
    t.bigint "theme_id"
    t.string "built_website", default: "Not Started"
    t.boolean "published", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "domain_purchased", default: false
    t.json "domain_purchase_details"
    t.text "domain_purchase_error"
    t.json "dns_configurations", default: {}
    t.index ["theme_id"], name: "index_user_setups_on_theme_id"
    t.index ["user_id"], name: "index_user_setups_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "role", default: 1, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "first_address_line"
    t.string "second_address_line"
    t.string "town"
    t.string "county"
    t.string "state_province"
    t.string "postcode"
    t.string "country"
    t.json "business_info"
    t.string "site_url_prefix"
    t.string "account_language"
    t.string "otp_secret_key"
    t.integer "consumed_timestep"
    t.boolean "otp_required_for_login", default: false
    t.text "otp_backup_codes"
    t.json "email_preferences", default: {"special_offers" => true, "contests_and_events" => true, "new_features_and_releases" => true, "tips_and_inspiration" => true}
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "websites", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "theme_id", null: false
    t.string "domain_name"
    t.string "name"
    t.text "description"
    t.json "pages"
    t.json "customisations"
    t.json "services"
    t.json "blogs"
    t.json "products"
    t.boolean "published"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.json "settings"
    t.json "categories", default: {"blogs" => {}, "services" => {}, "products" => {}}
    t.index ["theme_id"], name: "index_websites_on_theme_id"
    t.index ["user_id"], name: "index_websites_on_user_id", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "login_activities", "users"
  add_foreign_key "notifications", "users"
  add_foreign_key "solid_queue_blocked_executions", "solid_queue_jobs", column: "job_id"
  add_foreign_key "solid_queue_claimed_executions", "solid_queue_jobs", column: "job_id"
  add_foreign_key "solid_queue_failed_executions", "solid_queue_jobs", column: "job_id"
  add_foreign_key "solid_queue_ready_executions", "solid_queue_jobs", column: "job_id"
  add_foreign_key "solid_queue_scheduled_executions", "solid_queue_jobs", column: "job_id"
  add_foreign_key "user_connections", "users"
  add_foreign_key "user_setups", "themes"
  add_foreign_key "user_setups", "users"
  add_foreign_key "websites", "themes"
  add_foreign_key "websites", "users"
end
