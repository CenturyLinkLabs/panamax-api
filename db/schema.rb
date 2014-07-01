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

ActiveRecord::Schema.define(version: 20140528192410) do

  create_table "app_categories", force: true do |t|
    t.string   "name"
    t.integer  "app_id"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "app_categories", ["name", "app_id"], name: "index_app_categories_on_name_and_app_id", unique: true

  create_table "apps", force: true do |t|
    t.string "name"
    t.string "from"
    t.text   "documentation"
  end

  create_table "images", force: true do |t|
    t.string   "image_id"
    t.string   "name"
    t.string   "source"
    t.text     "description"
    t.string   "categories"
    t.boolean  "recommended"
    t.string   "type"
    t.text     "links"
    t.text     "ports"
    t.text     "expose"
    t.text     "environment"
    t.text     "volumes"
    t.integer  "template_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "images", ["image_id"], name: "index_images_on_image_id", unique: true
  add_index "images", ["source"], name: "index_images_on_source"

  create_table "service_categories", force: true do |t|
    t.integer  "service_id"
    t.integer  "app_category_id"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "service_categories", ["app_category_id"], name: "index_service_categories_on_app_category_id"
  add_index "service_categories", ["service_id", "app_category_id"], name: "index_service_categories_on_service_id_and_app_category_id", unique: true
  add_index "service_categories", ["service_id"], name: "index_service_categories_on_service_id"

  create_table "service_links", force: true do |t|
    t.integer  "linked_to_service_id"
    t.integer  "linked_from_service_id"
    t.string   "alias"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "service_links", ["linked_from_service_id", "linked_to_service_id"], name: "index_service_link_keys", unique: true
  add_index "service_links", ["linked_from_service_id"], name: "index_service_links_on_linked_from_service_id"
  add_index "service_links", ["linked_to_service_id"], name: "index_service_links_on_linked_to_service_id"

  create_table "services", force: true do |t|
    t.string  "name"
    t.text    "description"
    t.text    "from"
    t.text    "ports"
    t.text    "expose"
    t.text    "environment"
    t.text    "volumes"
    t.string  "type"
    t.integer "app_id"
  end

  add_index "services", ["app_id"], name: "index_services_on_app_id"
  add_index "services", ["name"], name: "index_services_on_name"

  create_table "template_repos", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "template_repos", ["name"], name: "index_template_repos_on_name", unique: true

  create_table "templates", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.string   "keywords"
    t.text     "authors"
    t.boolean  "recommended"
    t.string   "from"
    t.string   "type"
    t.text     "documentation"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "templates", ["keywords"], name: "index_templates_on_keywords"
  add_index "templates", ["name"], name: "index_templates_on_name"

  create_table "users", force: true do |t|
    t.string "github_access_token"
  end

end
