class InstallmentPlan < ApplicationRecord
  include Auditable

  belongs_to :user, optional: true
  belongs_to :category, optional: true
  belongs_to :payment_method, optional: true
  has_many :transactions, dependent: :destroy
  has_many :transaction_items, dependent: :destroy

  validates :name, presence: true
  validates :total_amount, numericality: { greater_than: 0 }
  validates :total_installments, numericality: { greater_than: 0, only_integer: true }
  validates :interval_in_months, numericality: { greater_than: 0, only_integer: true }
  validates :start_date, :end_date, presence: true

  def average_installment_amount
    total_amount / total_installments
  end
end
