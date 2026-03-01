class MealEntry < ApplicationRecord
  belongs_to :day_log
  has_many :meal_items, dependent: :destroy

  validates :meal_type, presence: true
  validates :occurred_at, presence: true
end
