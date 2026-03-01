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

ActiveRecord::Schema[8.1].define(version: 2026_03_01_015234) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "day_logs", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "local_data", null: false
    t.text "timezone", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id", "local_data"], name: "index_day_logs_on_user_id_and_local_data", unique: true
    t.index ["user_id"], name: "index_day_logs_on_user_id"
  end

  create_table "food_items", force: :cascade do |t|
    t.string "brand"
    t.datetime "created_at", null: false
    t.string "default_unit", null: false
    t.datetime "deleted_at"
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index "user_id, lower((name)::text)", name: "ix_food_items_user_name", where: "(deleted_at IS NULL)"
    t.index "user_id, lower((name)::text), COALESCE(lower((brand)::text), ''::text)", name: "ux_food_items_user_name_brand", unique: true, where: "(deleted_at IS NULL)"
    t.index ["deleted_at"], name: "ix_food_items_deleted_at"
    t.index ["user_id"], name: "index_food_items_on_user_id"
  end

  create_table "food_nutritions", force: :cascade do |t|
    t.float "basis_amount", null: false
    t.string "basis_unit", null: false
    t.float "calories", default: 0.0, null: false
    t.float "carbo", default: 0.0, null: false
    t.datetime "created_at", null: false
    t.float "fat", default: 0.0, null: false
    t.float "fiber", default: 0.0, null: false
    t.bigint "food_item_id", null: false
    t.float "protein", default: 0.0, null: false
    t.float "sugar", default: 0.0, null: false
    t.datetime "updated_at", null: false
    t.index ["food_item_id"], name: "index_food_nutritions_on_food_item_id"
    t.check_constraint "basis_amount > 0::double precision", name: "chk_basis_amount_positive"
    t.check_constraint "calories >= 0::double precision", name: "chk_fn_calories_non_negative"
    t.check_constraint "carbo >= 0::double precision", name: "chk_fn_carbo_non_negative"
    t.check_constraint "fat >= 0::double precision", name: "chk_fn_fat_non_negative"
    t.check_constraint "fiber >= 0::double precision", name: "chk_fn_fiber_non_negative"
    t.check_constraint "protein >= 0::double precision", name: "chk_fn_protein_non_negative"
    t.check_constraint "sugar >= 0::double precision", name: "chk_fn_sugar_non_negative"
  end

  create_table "jwt_denylist", force: :cascade do |t|
    t.datetime "exp", null: false
    t.string "jti", null: false
    t.index ["jti"], name: "index_jwt_denylist_on_jti", unique: true
  end

  create_table "meal_entries", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "day_log_id", null: false
    t.text "meal_type", null: false
    t.text "notes"
    t.date "occurred_at", null: false
    t.datetime "updated_at", null: false
    t.index ["day_log_id", "occurred_at"], name: "ix_meal_entries_day_time"
    t.index ["day_log_id"], name: "index_meal_entries_on_day_log_id"
  end

  create_table "meal_item_snapshots", force: :cascade do |t|
    t.float "calories", default: 0.0, null: false
    t.date "captured_at", null: false
    t.float "carbo", default: 0.0, null: false
    t.datetime "created_at", null: false
    t.float "fat", default: 0.0, null: false
    t.float "fiber", default: 0.0, null: false
    t.bigint "meal_item_id", null: false
    t.float "protein", default: 0.0, null: false
    t.float "sugar", default: 0.0, null: false
    t.datetime "updated_at", null: false
    t.index ["meal_item_id"], name: "index_meal_item_snapshots_on_meal_item_id"
    t.check_constraint "calories >= 0::double precision", name: "chk_mis_calories_non_negative"
    t.check_constraint "carbo >= 0::double precision", name: "chk_mis_carbo_non_negative"
    t.check_constraint "fat >= 0::double precision", name: "chk_mis_fat_non_negative"
    t.check_constraint "fiber >= 0::double precision", name: "chk_mis_fiber_non_negative"
    t.check_constraint "protein >= 0::double precision", name: "chk_mis_protein_non_negative"
    t.check_constraint "sugar >= 0::double precision", name: "chk_mis_sugar_non_negative"
  end

  create_table "meal_items", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "itemable_id", null: false
    t.string "itemable_type", null: false
    t.bigint "meal_entry_id", null: false
    t.float "quantity", null: false
    t.string "unit", null: false
    t.datetime "updated_at", null: false
    t.index ["itemable_type", "itemable_id"], name: "index_meal_items_on_itemable"
    t.index ["meal_entry_id"], name: "index_meal_items_on_meal_entry_id"
    t.check_constraint "quantity > 0::double precision", name: "chk_mi_quantity_positive"
  end

  create_table "recipe_ingredients", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "food_item_id", null: false
    t.string "name", null: false
    t.float "quantity", null: false
    t.bigint "recipe_id", null: false
    t.string "unit", null: false
    t.datetime "updated_at", null: false
    t.index ["food_item_id"], name: "index_recipe_ingredients_on_food_item_id"
    t.index ["recipe_id", "food_item_id"], name: "ux_recipe_ingredients_unique_food", unique: true
    t.index ["recipe_id"], name: "index_recipe_ingredients_on_recipe_id"
    t.check_constraint "quantity > 0::double precision", name: "chk_ri_quantity_positive"
  end

  create_table "recipe_nutrition_caches", force: :cascade do |t|
    t.float "calories", default: 0.0, null: false
    t.float "carbo", default: 0.0, null: false
    t.datetime "created_at", null: false
    t.float "fat", default: 0.0, null: false
    t.float "fiber", default: 0.0, null: false
    t.float "protein", default: 0.0, null: false
    t.bigint "recipe_id", null: false
    t.float "sugar", default: 0.0, null: false
    t.datetime "updated_at", null: false
    t.index ["recipe_id"], name: "index_recipe_nutrition_caches_on_recipe_id"
    t.check_constraint "calories >= 0::double precision", name: "chk_rnc_calories_non_negative"
    t.check_constraint "carbo >= 0::double precision", name: "chk_rnc_carbo_non_negative"
    t.check_constraint "fat >= 0::double precision", name: "chk_rnc_fat_non_negative"
    t.check_constraint "fiber >= 0::double precision", name: "chk_rnc_fiber_non_negative"
    t.check_constraint "protein >= 0::double precision", name: "chk_rnc_protein_non_negative"
    t.check_constraint "sugar >= 0::double precision", name: "chk_rnc_sugar_non_negative"
  end

  create_table "recipes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "deleted_at"
    t.string "name", null: false
    t.text "notes"
    t.float "servings", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index "user_id, lower((name)::text)", name: "ix_recipes_user_name", where: "(deleted_at IS NULL)"
    t.index ["deleted_at"], name: "ix_recipes_deleted_at"
    t.index ["user_id"], name: "index_recipes_on_user_id"
    t.check_constraint "servings > 0::double precision", name: "chk_servings_positive"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "confirmation_sent_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "name", null: false
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.string "unconfirmed_email"
    t.datetime "updated_at", null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "day_logs", "users", on_delete: :cascade
  add_foreign_key "food_items", "users", on_delete: :cascade
  add_foreign_key "food_nutritions", "food_items", on_delete: :cascade
  add_foreign_key "meal_entries", "day_logs", on_delete: :cascade
  add_foreign_key "meal_item_snapshots", "meal_items", on_delete: :cascade
  add_foreign_key "meal_items", "meal_entries", on_delete: :cascade
  add_foreign_key "recipe_ingredients", "food_items", on_delete: :cascade
  add_foreign_key "recipe_ingredients", "recipes", on_delete: :cascade
  add_foreign_key "recipe_nutrition_caches", "recipes", on_delete: :cascade
  add_foreign_key "recipes", "users", on_delete: :cascade
end
