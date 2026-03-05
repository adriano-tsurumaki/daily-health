require "test_helper"

class CategoryTest < ActiveSupport::TestCase
  test "should require name" do
    c = Category.new(user: users(:user_email_confirmed))
    assert_not c.valid?
    assert_includes c.errors[:name], "can't be blank"
  end

  test "should soft delete" do
    c = categories(:food_category)
    c.soft_delete!
    assert c.discarded?
    assert Category.kept.where(id: c.id).empty?
  end
end
