class InstallmentPlan < ApplicationRecord
  include Auditable

  has_many :transactions, dependent: :destroy
  has_many :transaction_items, dependent: :destroy

  validates :total_amount, numericality: { greater_than: 0 }
  validates :total_installments, numericality: { greater_than: 0, only_integer: true }
  validates :interval_in_months, numericality: { greater_than: 0, only_integer: true }
  validates :start_date, :end_date, presence: true
end
