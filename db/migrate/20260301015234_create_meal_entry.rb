class CreateMealEntry < ActiveRecord::Migration[8.1]
  def change
    create_table :meal_entries do |t|
      t.references :day_log, null: false, foreign_key: { on_delete: :cascade }

      t.text :meal_type, null: false
      t.date :occurred_at, null: false
      t.text :notes

      t.timestamps
    end

    add_index :meal_entries, [ :day_log_id, :occurred_at ],
      name: "ix_meal_entries_day_time"

    create_table :meal_items do |t|
      t.references :meal_entry, null: false, foreign_key: { on_delete: :cascade }
      t.references :itemable, null: false, polymorphic: true

      t.float :quantity, null: false
      t.string :unit, null: false

      t.timestamps
    end

    add_check_constraint :meal_items, "quantity > 0", name: "chk_mi_quantity_positive"

    create_table :meal_item_snapshots do |t|
      t.references :meal_item, null: false, foreign_key: { on_delete: :cascade }

      t.float :calories, null: false, default: 0.0
      t.float :carbo, null: false, default: 0.0
      t.float :protein, null: false, default: 0.0
      t.float :fat, null: false, default: 0.0
      t.float :fiber, null: false, default: 0.0
      t.float :sugar, null: false, default: 0.0
      t.date :captured_at, null: false

      t.timestamps
    end

    add_check_constraint :meal_item_snapshots, "calories >= 0", name: "chk_mis_calories_non_negative"
    add_check_constraint :meal_item_snapshots, "carbo >= 0", name: "chk_mis_carbo_non_negative"
    add_check_constraint :meal_item_snapshots, "protein >= 0", name: "chk_mis_protein_non_negative"
    add_check_constraint :meal_item_snapshots, "fat >= 0", name: "chk_mis_fat_non_negative"
    add_check_constraint :meal_item_snapshots, "fiber >= 0", name: "chk_mis_fiber_non_negative"
    add_check_constraint :meal_item_snapshots, "sugar >= 0", name: "chk_mis_sugar_non_negative"
  end
end
