class Category < ApplicationRecord
  include Auditable

  belongs_to :user
  has_many :transactions, dependent: :nullify

  validates :name, presence: true
end
