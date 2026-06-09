# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends
# to be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_02_23_214109) do
  create_table "ruby_llm_monitoring_events", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "allocations"
    t.float "cost"
    t.float "cpu_time"
    t.datetime "created_at", null: false
    t.float "duration"
    t.float "end"
    t.virtual "exception_class", type: :string, as: "json_unquote(json_extract(`payload`,_utf8mb4'$.exception[0]'))", stored: true
    t.virtual "exception_message", type: :string, as: "json_unquote(json_extract(`payload`,_utf8mb4'$.exception[1]'))", stored: true
    t.float "gc_time"
    t.float "idle_time"
    t.virtual "input_tokens", type: :integer, as: "cast(json_unquote(json_extract(`payload`,_utf8mb4'$.input_tokens')) as unsigned)", stored: true
    t.virtual "model", type: :string, as: "json_unquote(json_extract(`payload`,_utf8mb4'$.model'))", stored: true
    t.string "name"
    t.virtual "output_tokens", type: :integer, as: "cast(json_unquote(json_extract(`payload`,_utf8mb4'$.output_tokens')) as unsigned)", stored: true
    t.json "payload"
    t.virtual "provider", type: :string, as: "json_unquote(json_extract(`payload`,_utf8mb4'$.provider'))", stored: true
    t.virtual "thinking_tokens", type: :integer, as: "cast(json_unquote(json_extract(`payload`,_utf8mb4'$.thinking_tokens')) as unsigned)", stored: true
    t.float "time"
    t.string "transaction_id"
    t.datetime "updated_at", null: false
  end
end
