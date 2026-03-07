class PaymentMethod < ApplicationRecord
  include Auditable

  has_many :transactions, dependent: :restrict_with_error

  enum :identifier, { unknown: 0, credit_card: 1, debit_card: 2, cash: 3, pix: 4, boleto: 5 }

  validates :name, presence: true
  validates :locale, presence: true
end
