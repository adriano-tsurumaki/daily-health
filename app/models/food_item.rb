class FoodItem < ApplicationRecord
  belongs_to :user
  has_one :food_nutrition, dependent: :destroy
  has_many :recipe_ingredients, dependent: :restrict_with_error

  validates :name, presence: true
  validates :default_unit, presence: true
end
