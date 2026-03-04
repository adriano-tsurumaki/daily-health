class FoodItem < ApplicationRecord
  belongs_to :user
  has_one :food_nutrition, dependent: :destroy
  has_many :recipe_ingredients, dependent: :restrict_with_error

  accepts_nested_attributes_for :food_nutrition, update_only: true

  default_scope { where(deleted_at: nil) }

  validates :name, presence: true
  validates :default_unit, presence: true
  validates :name, uniqueness: {
    scope: :user_id,
    conditions: -> { where(deleted_at: nil) },
    message: "já existe um alimento com este nome"
  }

  def soft_delete!
    update_column(:deleted_at, Time.current)
  end
end
