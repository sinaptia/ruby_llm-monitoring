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

ActiveRecord::Schema[8.1].define(version: 2025_12_08_171258) do
  create_table "ruby_llm_monitoring_events", force: :cascade do |t|
    t.integer "allocations"
    t.float "cost"
    t.float "cpu_time"
    t.datetime "created_at", null: false
    t.float "duration"
    t.float "end"
    t.virtual "exception_class", type: :string, as: "json_extract(payload, '$.exception[0]')", stored: true
    t.virtual "exception_message", type: :string, as: "json_extract(payload, '$.exception[1]')", stored: true
    t.float "gc_time"
    t.float "idle_time"
    t.virtual "input_tokens", type: :integer, as: "CAST(payload->>'input_tokens' AS INTEGER)", stored: true
    t.virtual "model", type: :string, as: "payload->>'model'", stored: true
    t.string "name"
    t.virtual "output_tokens", type: :integer, as: "CAST(payload->>'output_tokens' AS INTEGER)", stored: true
    t.json "payload"
    t.virtual "provider", type: :string, as: "payload->>'provider'", stored: true
    t.float "time"
    t.string "transaction_id"
    t.datetime "updated_at", null: false
  end
end
