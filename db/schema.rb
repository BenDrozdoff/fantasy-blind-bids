# frozen_string_literal: true

# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2022_02_06_213226) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_admin_comments", force: :cascade do |t|
    t.string "namespace"
    t.text "body"
    t.string "resource_type"
    t.bigint "resource_id"
    t.string "author_type"
    t.bigint "author_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index %w(author_type author_id), name: "index_active_admin_comments_on_author_type_and_author_id"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index %w(resource_type resource_id), name: "index_active_admin_comments_on_resource_type_and_resource_id"
  end

  create_table "auctions", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_auctions_on_name", unique: true
  end

  create_table "bids", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "item_id", null: false
    t.integer "value", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index %w(user_id item_id), name: "index_bids_on_user_id_and_item_id", unique: true
  end

  create_table "items", force: :cascade do |t|
    t.string "name", null: false
    t.integer "auction_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "starting_price", default: 1, null: false
    t.integer "final_price"
    t.datetime "closes_at"
    t.integer "owner_id", null: false
    t.integer "winner_id"
    t.integer "status", default: 0
    t.string "arb_status"
  end

  create_table "memberships", id: false, force: :cascade do |t|
    t.integer "auction_id", null: false
    t.integer "user_id", null: false
    t.index ["auction_id"], name: "index_memberships_on_auction_id"
    t.index ["user_id"], name: "index_memberships_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end
end
