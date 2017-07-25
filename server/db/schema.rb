# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170721200943) do

  create_table "input_files", force: :cascade do |t|
    t.integer "job_id"
    t.integer "job_file_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["job_file_id"], name: "index_input_files_on_job_file_id"
    t.index ["job_id"], name: "index_input_files_on_job_id"
  end

  create_table "job_files", force: :cascade do |t|
    t.string "name"
    t.binary "contents"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "jobs", force: :cascade do |t|
    t.string "status"
    t.integer "job_file_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["job_file_id"], name: "index_jobs_on_job_file_id"
  end

  create_table "logs", force: :cascade do |t|
    t.integer "executable_id"
    t.integer "state_file_id"
    t.integer "order"
    t.text "contents"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["executable_id"], name: "index_logs_on_executable_id"
    t.index ["state_file_id"], name: "index_logs_on_state_file_id"
  end

  create_table "output_files", force: :cascade do |t|
    t.integer "job_id"
    t.integer "job_file_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["job_file_id"], name: "index_output_files_on_job_file_id"
    t.index ["job_id"], name: "index_output_files_on_job_id"
  end

  create_table "results", force: :cascade do |t|
    t.integer "job_id"
    t.integer "order"
    t.text "contents"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["job_id"], name: "index_results_on_job_id"
  end

end
