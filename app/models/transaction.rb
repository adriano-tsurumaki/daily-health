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

  before_validation :normalize_income_status

  validates :amount, presence: true
  validates :payment_date, presence: true
  validates :description, presence: true
  validates :status, inclusion: { in: %w[paid cancelled] }, if: -> { income? || refund? }

  def normalize_income_status
    self.status = :paid if (income? || refund?) && !cancelled?
  end

  def review_status
    return "needs_category" if category_id.nil?
    return "needs_instrument_review" if payment_method&.review_status != "ok"

    "ok"
  end

  def entry_state
    paid? ? "realized" : "committed"
  end

  def period_bucket
    Finance::CommitmentRules.bucket_for_transaction(self)
  end

  def commitment_date
    Finance::CommitmentRules.commitment_date_for_transaction(self)
  end
end
