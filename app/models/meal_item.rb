class MealItem < ApplicationRecord
  belongs_to :meal_entry
  belongs_to :itemable, polymorphic: true
  has_one :meal_item_snapshot, dependent: :destroy

  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :unit, presence: true
end
