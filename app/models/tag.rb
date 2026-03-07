class Tag < ApplicationRecord
  include Auditable

  has_many :transaction_tags, dependent: :destroy
  has_many :transactions, through: :transaction_tags

  validates :name, presence: true, uniqueness: true
end
