class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :validatable, :confirmable,
         :jwt_authenticatable, jwt_revocation_strategy: JwtDenylist

  has_many :day_logs, dependent: :destroy
  has_many :food_items, dependent: :destroy
  has_many :recipes, dependent: :destroy

  def confirmed_at
    self[:confirmed_at]
  end

  def confirmed_at=(val)
    write_attribute(:confirmed_at, val)
  end
end
