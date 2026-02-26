class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :validatable, :confirmable,
         :jwt_authenticatable, jwt_revocation_strategy: JwtDenylist

  def confirmed_at
    self[:confirmed_at]
  end

  def confirmed_at=(val)
    write_attribute(:confirmed_at, val)
  end
end
