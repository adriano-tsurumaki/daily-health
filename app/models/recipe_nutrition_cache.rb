class RecipeNutritionCache < ApplicationRecord
  belongs_to :recipe

  validates :calories, :carbo, :protein, :fat, :fiber, :sugar,
            presence: true, numericality: { greater_than_or_equal_to: 0 }
end
