class CreateFinancialEntities < ActiveRecord::Migration[8.1]
  def change
    create_table :categories do |t|
      t.uuid :uuid, null: false, default: "gen_random_uuid()"
      t.string :name, null: false
      t.references :user, null: false, foreign_key: { on_delete: :cascade }
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :categories, :deleted_at, name: "ix_categories_deleted_at"

    create_table :tags do |t|
      t.uuid :uuid, null: false, default: "gen_random_uuid()"
      t.string :name, null: false
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :tags, :name, unique: true
    add_index :tags, :deleted_at, name: "ix_tags_deleted_at"

    create_table :payment_methods do |t|
      t.uuid :uuid, null: false, default: "gen_random_uuid()"
      t.string :name, null: false
      t.string :locale, null: false
      t.integer :identifier, null: false, default: 0
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :payment_methods, :deleted_at, name: "ix_payment_methods_deleted_at"

    create_table :recurrences do |t|
      t.uuid :uuid, null: false, default: "gen_random_uuid()"
      t.boolean :is_active, null: false
      t.integer :frequency, null: false
      t.integer :recurrence_interval, null: false
      t.datetime :end_date
      t.datetime :next_due_date, null: false
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :recurrences, :deleted_at, name: "ix_recurrences_deleted_at"

    create_table :installment_plans do |t|
      t.uuid :uuid, null: false, default: "gen_random_uuid()"
      t.decimal :total_amount, precision: 10, scale: 2, null: false
      t.integer :total_installments, null: false
      t.datetime :start_date, null: false
      t.datetime :end_date, null: false
      t.integer :interval_in_months, null: false
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :installment_plans, :deleted_at, name: "ix_installment_plans_deleted_at"

    create_table :transactions do |t|
      t.uuid :uuid, null: false, default: "gen_random_uuid()"
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.datetime :payment_date, null: false
      t.integer :transaction_type, null: false
      t.integer :status, null: false, default: 0
      t.references :user, null: false, foreign_key: { on_delete: :cascade }
      t.references :payment_method, null: false, foreign_key: true
      t.references :category, foreign_key: { on_delete: :nullify }
      t.references :recurrence, foreign_key: { on_delete: :nullify }
      t.references :installment_plan, foreign_key: { on_delete: :cascade }
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :transactions, :deleted_at, name: "ix_transactions_deleted_at"

    create_table :transaction_items do |t|
      t.uuid :uuid, null: false, default: "gen_random_uuid()"
      t.string :name, null: false
      t.decimal :quantity, precision: 10, scale: 4, null: false
      t.string :unit_of_measure, null: false
      t.decimal :unit_price, precision: 10, scale: 2, null: false
      t.references :transaction, foreign_key: { on_delete: :cascade }
      t.references :installment_plan, foreign_key: { on_delete: :cascade }
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :transaction_items, :deleted_at, name: "ix_transaction_items_deleted_at"

    create_table :transaction_tags, id: false do |t|
      t.references :transaction, null: false, foreign_key: { on_delete: :cascade }
      t.references :tag, null: false, foreign_key: { on_delete: :cascade }
    end

    add_index :transaction_tags, [ :transaction_id, :tag_id ], unique: true, name: "ux_transaction_tags"
  end
end
