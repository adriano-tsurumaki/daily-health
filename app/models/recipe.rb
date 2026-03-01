class Recipe < ApplicationRecord
  belongs_to :user
  has_many :recipe_ingredients, dependent: :destroy
  has_one :recipe_nutrition_cache, dependent: :destroy

  validates :name, presence: true
  validates :servings, presence: true, numericality: { greater_than: 0 }
end
