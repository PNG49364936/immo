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

ActiveRecord::Schema[7.1].define(version: 2026_10_26_114714) do
  create_table "arrondissements", force: :cascade do |t|
    t.integer "number"
    t.string "insee_code"
    t.string "name"
    t.string "official_name"
    t.text "geojson"
    t.integer "median_price_m2"
    t.integer "sales_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["insee_code"], name: "index_arrondissements_on_insee_code", unique: true
    t.index ["number"], name: "index_arrondissements_on_number", unique: true
  end

  create_table "dvf_imports", force: :cascade do |t|
    t.string "status", default: "pending", null: false
    t.datetime "started_at"
    t.datetime "finished_at"
    t.integer "sales_count", default: 0, null: false
    t.date "data_from"
    t.date "data_until"
    t.text "error_message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sales", force: :cascade do |t|
    t.string "mutation_id"
    t.date "sold_on"
    t.integer "price"
    t.integer "surface"
    t.integer "rooms"
    t.string "property_type"
    t.string "address"
    t.float "lat"
    t.float "lng"
    t.integer "price_m2"
    t.integer "arrondissement_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["arrondissement_id"], name: "index_sales_on_arrondissement_id"
    t.index ["mutation_id"], name: "index_sales_on_mutation_id", unique: true
    t.index ["price_m2"], name: "index_sales_on_price_m2"
    t.index ["sold_on"], name: "index_sales_on_sold_on"
  end

  add_foreign_key "sales", "arrondissements"
end
