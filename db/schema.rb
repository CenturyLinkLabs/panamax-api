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

ActiveRecord::Schema.define(version: 20140326201625) do

  create_table "images", force: true do |t|
    t.string   "image_id"
    t.string   "repository"
    t.string   "tag"
    t.text     "description"
    t.string   "keywords"
    t.boolean  "recommended"
    t.string   "icon"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "images", ["image_id"], name: "index_images_on_image_id", unique: true
  add_index "images", ["repository"], name: "index_images_on_repository"

  create_table "images_templates", force: true do |t|
    t.integer "template_id"
    t.integer "image_id"
  end

  create_table "templates", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.string   "keywords"
    t.boolean  "recommended"
    t.string   "icon"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "templates", ["name"], name: "index_templates_on_name"

end
