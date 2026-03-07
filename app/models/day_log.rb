class DayLog < ApplicationRecord
  belongs_to :user
  has_many :meal_entries, dependent: :destroy

  validates :local_data, presence: true
  validates :timezone, presence: true
  validates :local_data, uniqueness: { scope: :user_id }
end
