require "test_helper"

class TagTest < ActiveSupport::TestCase
  test "should require name" do
    t = Tag.new
    assert_not t.valid?
    assert_includes t.errors[:name], "can't be blank"
  end

  test "should require unique name" do
    Tag.create!(name: "Único")
    t = Tag.new(name: "Único")
    assert_not t.valid?
    assert_includes t.errors[:name], "has already been taken"
  end

  test "should soft delete" do
    t = tags(:leisure)
    t.soft_delete!
    assert t.discarded?
    assert Tag.kept.where(id: t.id).empty?
  end
end
