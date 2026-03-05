class TransactionItem < ApplicationRecord
  include Auditable

  belongs_to :financial_transaction, class_name: "Transaction", foreign_key: :transaction_id, optional: true
  belongs_to :installment_plan, optional: true

  validates :name, presence: true
  validates :quantity, numericality: { greater_than: 0 }
  validates :unit_of_measure, presence: true
  validates :unit_price, numericality: { greater_than_or_equal_to: 0 }

  def total
    quantity * unit_price
  end
end
