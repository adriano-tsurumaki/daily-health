class FoodNutrition < ApplicationRecord
  belongs_to :food_item

  validates :basis_amount, presence: true, numericality: { greater_than: 0 }
  validates :basis_unit, presence: true
  validates :calories, :carbo, :protein, :fat, :fiber, :sugar,
            presence: true, numericality: { greater_than_or_equal_to: 0 }
end
