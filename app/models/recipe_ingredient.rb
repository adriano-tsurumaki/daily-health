class RecipeIngredient < ApplicationRecord
  belongs_to :recipe
  belongs_to :food_item

  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :unit, presence: true
  validates :food_item_id, uniqueness: { scope: :recipe_id }
end
