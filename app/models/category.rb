class Category < ApplicationRecord
  include Auditable

  belongs_to :user
  has_many :transactions, dependent: :nullify
  has_many :recurrences, dependent: :nullify

  validates :name, presence: true
  validates :color, presence: true
  validates :monthly_limit, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  before_validation :apply_defaults

  private

  def apply_defaults
    self.color = "#f59e0b" if color.blank?
  end
end
