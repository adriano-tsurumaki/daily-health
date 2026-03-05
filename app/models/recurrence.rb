class Recurrence < ApplicationRecord
  include Auditable

  has_many :transactions, dependent: :nullify

  enum :frequency, { daily: 0, weekly: 1, monthly: 2, yearly: 3 }

  validates :recurrence_interval, numericality: { greater_than: 0 }
  validates :next_due_date, presence: true
end
