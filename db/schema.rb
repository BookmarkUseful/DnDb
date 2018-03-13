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

ActiveRecord::Schema.define(version: 20180312234050) do

  create_table "authors", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean  "trusted"
    t.string   "slug"
  end

  create_table "backgrounds", force: :cascade do |t|
    t.string   "name"
    t.string   "slug"
    t.text     "description"
    t.string   "feature_name"
    t.text     "feature_description"
    t.text     "tool_proficiencies",  default: "[]"
    t.text     "equipment",           default: "[]"
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.integer  "source_id"
  end

  add_index "backgrounds", ["source_id"], name: "index_backgrounds_on_source_id"

  create_table "backgrounds_skills", id: false, force: :cascade do |t|
    t.integer "skill_id",      null: false
    t.integer "background_id", null: false
  end

  add_index "backgrounds_skills", ["skill_id", "background_id"], name: "index_backgrounds_skills_on_skill_id_and_background_id"

  create_table "character_classes", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.integer  "source_id"
    t.text     "summary"
    t.integer  "hit_die",             limit: 1
    t.string   "saving_throws"
    t.string   "spell_slots"
    t.integer  "spell_ability",       limit: 1
    t.text     "description"
    t.integer  "num_starting_skills"
    t.string   "subclass_descriptor"
    t.string   "slug"
  end

  add_index "character_classes", ["name"], name: "index_character_classes_on_name", unique: true
  add_index "character_classes", ["source_id"], name: "index_character_classes_on_source_id"

  create_table "character_classes_skills", id: false, force: :cascade do |t|
    t.integer "character_class_id", null: false
    t.integer "skill_id",           null: false
  end

  add_index "character_classes_skills", ["character_class_id"], name: "index_character_classes_skills_on_character_class_id"
  add_index "character_classes_skills", ["skill_id"], name: "index_character_classes_skills_on_skill_id"

  create_table "character_classes_spells", id: false, force: :cascade do |t|
    t.integer "character_class_id", null: false
    t.integer "spell_id",           null: false
  end

  create_table "feats", force: :cascade do |t|
    t.string   "name"
    t.text     "description"
    t.string   "prerequisite"
    t.integer  "source_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "slug"
  end

  add_index "feats", ["source_id"], name: "index_feats_on_source_id"

  create_table "features", force: :cascade do |t|
    t.string   "name"
    t.text     "description"
    t.string   "type"
    t.integer  "provider_id"
    t.integer  "level",       limit: 1
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.string   "slug"
  end

  create_table "items", force: :cascade do |t|
    t.string   "name"
    t.float    "weight"
    t.integer  "value"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.integer  "rarity",     default: 0
  end

  create_table "races", force: :cascade do |t|
    t.string   "name"
    t.string   "slug"
    t.text     "description"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "source_id"
  end

  add_index "races", ["source_id"], name: "index_races_on_source_id"

  create_table "skills", force: :cascade do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "ability",     limit: 1
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "slug"
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
    t.string   "slug"
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
    t.string   "source_name"
    t.string   "slug"
  end

  add_index "spells", ["name"], name: "index_spells_on_name", unique: true
  add_index "spells", ["source_id"], name: "index_spells_on_source_id"

  create_table "subclass_features", force: :cascade do |t|
    t.string  "name"
    t.text    "description"
    t.integer "level",       limit: 1
    t.integer "subclass_id",           null: false
  end

  create_table "subclasses", force: :cascade do |t|
    t.string   "name"
    t.integer  "character_class_id", null: false
    t.text     "description"
    t.integer  "source_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "slug"
  end

  add_index "subclasses", ["source_id"], name: "index_subclasses_on_source_id"

  create_table "subraces", force: :cascade do |t|
    t.string   "name"
    t.string   "slug"
    t.text     "description"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "source_id"
    t.integer  "race_id"
  end

  add_index "subraces", ["race_id"], name: "index_subraces_on_race_id"
  add_index "subraces", ["source_id"], name: "index_subraces_on_source_id"

end
