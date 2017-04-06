# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20170406220545) do

  create_table "authors", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean  "trusted"
    t.string   "permalink"
  end

  create_table "character_classes", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "source_id"
    t.text     "description"
    t.string   "permalink"
  end

  add_index "character_classes", ["name"], name: "index_character_classes_on_name", unique: true
  add_index "character_classes", ["source_id"], name: "index_character_classes_on_source_id"

  create_table "character_classes_spells", id: false, force: :cascade do |t|
    t.integer "character_class_id", null: false
    t.integer "spell_id",           null: false
  end

  create_table "items", force: :cascade do |t|
    t.string   "name"
    t.float    "weight"
    t.integer  "value"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.integer  "rarity",     default: 0
    t.string   "permalink"
  end

  create_table "sources", force: :cascade do |t|
    t.string   "name"
    t.integer  "page_count"
    t.integer  "kind"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.integer  "author_id"
    t.string   "link"
    t.boolean  "indexed",      default: false
    t.string   "abbreviation"
    t.string   "permalink"
  end

  add_index "sources", ["author_id"], name: "index_sources_on_author_id"

  create_table "spells", force: :cascade do |t|
    t.string   "name"
    t.integer  "level"
    t.integer  "school"
    t.integer  "casting_time"
    t.integer  "range"
    t.integer  "duration"
    t.string   "description"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.boolean  "concentration"
    t.boolean  "ritual"
    t.text     "components"
    t.integer  "source_id"
    t.integer  "parent_school"
    t.string   "source_name"
    t.string   "permalink"
  end

  add_index "spells", ["name"], name: "index_spells_on_name", unique: true
  add_index "spells", ["source_id"], name: "index_spells_on_source_id"

end
