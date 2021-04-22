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

ActiveRecord::Schema.define(version: 2021_04_11_172704) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

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
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "activities", force: :cascade do |t|
    t.string "title"
    t.string "state"
    t.date "start_date"
    t.date "end_date"
    t.date "close_date"
    t.integer "task_pending"
    t.integer "task_finished"
    t.bigint "work_plan_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["work_plan_id"], name: "index_activities_on_work_plan_id"
  end

  create_table "admins", force: :cascade do |t|
    t.string "email"
    t.string "name"
    t.string "first_lastname"
    t.string "second_lastname"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "commentaries", force: :cascade do |t|
    t.text "message"
    t.integer "issuer_id"
    t.date "issuer_date"
    t.string "state"
    t.bigint "activity_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["activity_id"], name: "index_commentaries_on_activity_id"
  end

  create_table "professor_summaries", force: :cascade do |t|
    t.integer "professor_id"
    t.string "name"
    t.string "first_lastname"
    t.string "second_lastname"
    t.string "grade"
    t.string "email"
    t.string "avatar"
    t.integer "num_tesis"
    t.float "num_tesis_med"
    t.integer "asignadas"
    t.float "dias_rev_med"
    t.boolean "academic"
    t.integer "num_tesis_abandonadas"
    t.float "tiempo_final_med"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "topicos", default: [], array: true
    t.integer "num_tesis_tot"
    t.string "grade_name"
  end

  create_table "proposals", force: :cascade do |t|
    t.integer "student_id"
    t.integer "professor_id"
    t.integer "topic_id"
    t.string "topic_name"
    t.string "title"
    t.text "summary"
    t.string "rute_document"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "semester"
    t.integer "year"
    t.string "student_name"
    t.string "professor_name"
    t.string "file"
  end

  create_table "student_summaries", force: :cascade do |t|
    t.integer "student_id"
    t.string "name"
    t.string "first_lastname"
    t.string "second_lastname"
    t.integer "year_income"
    t.string "email"
    t.integer "program_id"
    t.string "program_name"
    t.integer "num_temas"
    t.integer "num_guias"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "tasks", force: :cascade do |t|
    t.string "title"
    t.string "state"
    t.date "start_date"
    t.date "end_date"
    t.date "close_date"
    t.bigint "activity_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["activity_id"], name: "index_tasks_on_activity_id"
  end

  create_table "thesis_summaries", force: :cascade do |t|
    t.integer "thesis_id"
    t.integer "thype_id"
    t.string "topic"
    t.integer "program_id"
    t.string "status"
    t.integer "year"
    t.integer "semester"
    t.integer "dias_rev"
    t.string "student_name"
    t.string "student_first_lastname"
    t.string "student_second_lastname"
    t.string "guia_name"
    t.string "guia_first_lastname"
    t.string "guia_second_lastname"
    t.string "title"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "guide_id"
    t.string "guia_email"
    t.string "student_email"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "work_plans", force: :cascade do |t|
    t.string "state"
    t.boolean "suscription"
    t.integer "activity_pending"
    t.integer "activity_finished"
    t.integer "thesis_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "activities", "work_plans"
  add_foreign_key "commentaries", "activities"
  add_foreign_key "tasks", "activities"
end
