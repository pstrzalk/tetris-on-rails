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

ActiveRecord::Schema[7.0].define(version: 2023_09_06_083734) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "flags", force: :cascade do |t|
    t.string "key", null: false
  end

  create_table "games", force: :cascade do |t|
    t.uuid "player_id"
    t.integer "score", default: 0, null: false
    t.boolean "running", default: true
    t.text "board", array: true
    t.text "actions", array: true
    t.string "email"
    t.string "brick_shape"
    t.integer "brick_rotated_times"
    t.integer "brick_position_x"
    t.integer "brick_position_y"
    t.string "question_id"
    t.string "question_result"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "next_brick_shape"
    t.string "nickname"
  end

  create_table "timers", force: :cascade do |t|
    t.bigint "game_id"
    t.integer "tick", default: 0, null: false
    t.integer "question_tick", default: 0
    t.index ["game_id"], name: "index_timers_on_game_id"
  end

end
