class Transaction < ApplicationRecord
  include Auditable

  belongs_to :user
  belongs_to :payment_method
  belongs_to :category, optional: true
  belongs_to :recurrence, optional: true
  belongs_to :installment_plan, optional: true
  has_many :transaction_items, dependent: :destroy, inverse_of: :financial_transaction
  accepts_nested_attributes_for :transaction_items, allow_destroy: true, reject_if: :all_blank
  has_many :transaction_tags, dependent: :destroy, inverse_of: :financial_transaction
  has_many :tags, through: :transaction_tags

  enum :transaction_type, { expense: 0, income: 1, transfer: 2, refund: 3 }
  enum :status, { pending: 0, paid: 1, cancelled: 2, failed: 3, expired: 4 }

  validates :amount, presence: true
  validates :payment_date, presence: true
end
