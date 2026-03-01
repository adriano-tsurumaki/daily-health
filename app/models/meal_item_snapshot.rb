class MealItemSnapshot < ApplicationRecord
  belongs_to :meal_item

  validates :calories,  presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :carbo,     presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :protein,   presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :fat,       presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :fiber,     presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :sugar,     presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :captured_at, presence: true
end
