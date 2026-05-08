class ExpandFinanceCommitmentFeatures < ActiveRecord::Migration[8.1]
  def up
    add_reference :payment_methods, :user, foreign_key: { on_delete: :cascade }, null: true
    add_reference :recurrences, :user, foreign_key: { on_delete: :cascade }, null: true
    add_reference :installment_plans, :user, foreign_key: { on_delete: :cascade }, null: true

    add_column :payment_methods, :kind, :string, null: false, default: "account"
    add_column :payment_methods, :is_active, :boolean, null: false, default: true
    add_column :payment_methods, :display_color, :string, null: false, default: "#1d4ed8"
    add_column :payment_methods, :closing_day, :integer
    add_column :payment_methods, :due_day, :integer
    add_column :payment_methods, :credit_limit, :decimal, precision: 12, scale: 2

    add_column :categories, :monthly_limit, :decimal, precision: 12, scale: 2
    add_column :categories, :color, :string, null: false, default: "#f59e0b"

    add_column :transactions, :description, :string, null: false, default: ""
    add_column :transactions, :merchant_name, :string
    add_column :transactions, :due_date, :date
    add_column :transactions, :installment_position, :integer

    add_column :recurrences, :name, :string, null: false, default: ""
    add_column :recurrences, :amount, :decimal, precision: 12, scale: 2, null: false, default: 0
    add_reference :recurrences, :category, foreign_key: { on_delete: :nullify }
    add_reference :recurrences, :payment_method, foreign_key: true

    add_column :installment_plans, :name, :string
    add_column :installment_plans, :description, :string
    add_reference :installment_plans, :category, foreign_key: { on_delete: :nullify }
    add_reference :installment_plans, :payment_method, foreign_key: true

    backfill_payment_method_owners
    backfill_recurrence_owners
    backfill_installment_plan_owners

    execute <<~SQL
      UPDATE payment_methods
      SET kind = CASE identifier
        WHEN 1 THEN 'credit_card'
        WHEN 2 THEN 'account'
        WHEN 4 THEN 'instant'
        WHEN 3 THEN 'instant'
        WHEN 5 THEN 'instant'
        ELSE 'account'
      END
    SQL

    execute <<~SQL
      UPDATE payment_methods
      SET display_color = CASE kind
        WHEN 'credit_card' THEN '#1d4ed8'
        WHEN 'instant' THEN '#0f766e'
        ELSE '#6d28d9'
      END
      WHERE display_color IS NULL OR display_color = ''
    SQL

    execute <<~SQL
      UPDATE categories
      SET color = '#f59e0b'
      WHERE color IS NULL OR color = ''
    SQL

    execute <<~SQL
      UPDATE transactions
      SET description = 'Lançamento financeiro'
      WHERE description IS NULL OR description = ''
    SQL

    execute <<~SQL
      UPDATE transactions AS transactions
      SET description = categories.name
      FROM categories
      WHERE transactions.category_id = categories.id
        AND transactions.description = 'Lançamento financeiro'
    SQL

    execute <<~SQL
      UPDATE recurrences AS recurrences
      SET amount = source.amount,
          payment_method_id = source.payment_method_id,
          category_id = source.category_id
      FROM (
        SELECT DISTINCT ON (recurrence_id)
          recurrence_id,
          amount,
          payment_method_id,
          category_id
        FROM transactions
        WHERE recurrence_id IS NOT NULL
        ORDER BY recurrence_id, created_at ASC
      ) AS source
      WHERE recurrences.id = source.recurrence_id
    SQL

    execute <<~SQL
      UPDATE recurrences
      SET name = 'Recorrência ativa'
      WHERE name IS NULL OR name = ''
    SQL

    execute <<~SQL
      UPDATE installment_plans
      SET name = COALESCE(name, 'Parcelamento'),
          description = COALESCE(description, 'Parcelamento planejado')
      WHERE name IS NULL OR description IS NULL
    SQL
  end

  def down
    remove_reference :installment_plans, :payment_method, foreign_key: true
    remove_reference :installment_plans, :category, foreign_key: { on_delete: :nullify }
    remove_column :installment_plans, :description, :string
    remove_column :installment_plans, :name, :string

    remove_reference :recurrences, :payment_method, foreign_key: true
    remove_reference :recurrences, :category, foreign_key: { on_delete: :nullify }
    remove_column :recurrences, :amount, :decimal
    remove_column :recurrences, :name, :string

    remove_column :transactions, :installment_position, :integer
    remove_column :transactions, :due_date, :date
    remove_column :transactions, :merchant_name, :string
    remove_column :transactions, :description, :string

    remove_column :categories, :color, :string
    remove_column :categories, :monthly_limit, :decimal

    remove_column :payment_methods, :credit_limit, :decimal
    remove_column :payment_methods, :due_day, :integer
    remove_column :payment_methods, :closing_day, :integer
    remove_column :payment_methods, :display_color, :string
    remove_column :payment_methods, :is_active, :boolean
    remove_column :payment_methods, :kind, :string

    remove_reference :installment_plans, :user, foreign_key: { on_delete: :cascade }
    remove_reference :recurrences, :user, foreign_key: { on_delete: :cascade }
    remove_reference :payment_methods, :user, foreign_key: { on_delete: :cascade }
  end

  private

  def backfill_payment_method_owners
    execute <<~SQL
      UPDATE payment_methods AS payment_methods
      SET user_id = source.user_id
      FROM (
        SELECT
          payment_method_id,
          MIN(user_id) AS user_id,
          COUNT(DISTINCT user_id) AS user_count
        FROM transactions
        WHERE payment_method_id IS NOT NULL
        GROUP BY payment_method_id
      ) AS source
      WHERE payment_methods.id = source.payment_method_id
        AND source.user_count = 1
    SQL
  end

  def backfill_recurrence_owners
    execute <<~SQL
      UPDATE recurrences AS recurrences
      SET user_id = source.user_id
      FROM (
        SELECT
          recurrence_id,
          MIN(user_id) AS user_id,
          COUNT(DISTINCT user_id) AS user_count
        FROM transactions
        WHERE recurrence_id IS NOT NULL
        GROUP BY recurrence_id
      ) AS source
      WHERE recurrences.id = source.recurrence_id
        AND source.user_count = 1
    SQL
  end

  def backfill_installment_plan_owners
    execute <<~SQL
      UPDATE installment_plans AS installment_plans
      SET user_id = source.user_id
      FROM (
        SELECT
          installment_plan_id,
          MIN(user_id) AS user_id,
          COUNT(DISTINCT user_id) AS user_count
        FROM transactions
        WHERE installment_plan_id IS NOT NULL
        GROUP BY installment_plan_id
      ) AS source
      WHERE installment_plans.id = source.installment_plan_id
        AND source.user_count = 1
    SQL
  end
end
