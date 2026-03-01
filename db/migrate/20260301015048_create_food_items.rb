class CreateFoodItems < ActiveRecord::Migration[8.1]
  def change
    create_table :food_items do |t|
      t.references :user, null: false, foreign_key: { on_delete: :cascade }

      t.string :name, null: false
      t.string :brand
      t.string :default_unit, null: false
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :food_items, :deleted_at, name: "ix_food_items_deleted_at"

    execute <<~SQL
      CREATE INDEX ix_food_items_user_name
        ON food_items (user_id, lower(name))
        WHERE deleted_at IS NULL;
    SQL

    execute <<~SQL
      CREATE UNIQUE INDEX ux_food_items_user_name_brand
        ON food_items (user_id, lower(name), coalesce(lower(brand), ''))
        WHERE deleted_at IS NULL;
    SQL

    create_table :food_nutritions do |t|
      t.references :food_item, null: false, foreign_key: { on_delete: :cascade }

      t.float :basis_amount, null: false
      t.string :basis_unit, null: false

      t.float :calories, null: false, default: 0.0
      t.float :carbo, null: false, default: 0.0
      t.float :protein, null: false, default: 0.0
      t.float :fat, null: false, default: 0.0
      t.float :fiber, null: false, default: 0.0
      t.float :sugar, null: false, default: 0.0

      t.timestamps
    end

    add_check_constraint :food_nutritions, "basis_amount > 0", name: "chk_basis_amount_positive"
    add_check_constraint :food_nutritions, "calories >= 0", name: "chk_fn_calories_non_negative"
    add_check_constraint :food_nutritions, "carbo >= 0", name: "chk_fn_carbo_non_negative"
    add_check_constraint :food_nutritions, "protein >= 0", name: "chk_fn_protein_non_negative"
    add_check_constraint :food_nutritions, "fat >= 0", name: "chk_fn_fat_non_negative"
    add_check_constraint :food_nutritions, "fiber >= 0", name: "chk_fn_fiber_non_negative"
    add_check_constraint :food_nutritions, "sugar >= 0", name: "chk_fn_sugar_non_negative"
  end
end
