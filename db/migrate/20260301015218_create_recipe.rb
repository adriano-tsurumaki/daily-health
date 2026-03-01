class CreateRecipe < ActiveRecord::Migration[8.1]
  def change
    create_table :recipes do |t|
      t.references :user, null: false, foreign_key: { on_delete: :cascade }

      t.string :name, null: false
      t.float :servings, null: false
      t.text :notes
      t.datetime :deleted_at

      t.timestamps
    end

    add_check_constraint :recipes, "servings > 0", name: "chk_servings_positive"
    add_index :recipes, :deleted_at, name: "ix_recipes_deleted_at"
    execute <<~SQL
      CREATE INDEX ix_recipes_user_name
        ON recipes (user_id, lower(name))
        WHERE deleted_at IS NULL;
    SQL

    create_table :recipe_ingredients do |t|
      t.references :recipe, null: false, foreign_key: { on_delete: :cascade }
      t.references :food_item, null: false, foreign_key: { on_delete: :cascade }

      t.string :name, null: false
      t.float :quantity, null: false
      t.string :unit, null: false

      t.timestamps
    end

    add_check_constraint :recipe_ingredients, "quantity > 0", name: "chk_ri_quantity_positive"
    add_index :recipe_ingredients, [ :recipe_id, :food_item_id ],
      name: "ux_recipe_ingredients_unique_food",
      unique: true

    create_table :recipe_nutrition_caches do |t|
      t.references :recipe, null: false, foreign_key: { on_delete: :cascade }

      t.float :calories, null: false, default: 0.0
      t.float :carbo, null: false, default: 0.0
      t.float :protein, null: false, default: 0.0
      t.float :fat, null: false, default: 0.0
      t.float :fiber, null: false, default: 0.0
      t.float :sugar, null: false, default: 0.0

      t.timestamps
    end

    add_check_constraint :recipe_nutrition_caches, "calories >= 0", name: "chk_rnc_calories_non_negative"
    add_check_constraint :recipe_nutrition_caches, "carbo >= 0", name: "chk_rnc_carbo_non_negative"
    add_check_constraint :recipe_nutrition_caches, "protein >= 0", name: "chk_rnc_protein_non_negative"
    add_check_constraint :recipe_nutrition_caches, "fat >= 0", name: "chk_rnc_fat_non_negative"
    add_check_constraint :recipe_nutrition_caches, "fiber >= 0", name: "chk_rnc_fiber_non_negative"
    add_check_constraint :recipe_nutrition_caches, "sugar >= 0", name: "chk_rnc_sugar_non_negative"
  end
end
