class CreateDayLogs < ActiveRecord::Migration[8.1]
  def change
    create_table :day_logs do |t|
      t.references :user, null: false, foreign_key: { on_delete: :cascade }

      t.date :local_data, null: false
      t.text :timezone, null: false

      t.timestamps
    end

    add_index :day_logs, [ :user_id, :local_data ], unique: true
  end
end
