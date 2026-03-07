require "test_helper"

class PaymentMethodTest < ActiveSupport::TestCase
  test "should require name" do
    pm = PaymentMethod.new(locale: "pt_BR")
    assert_not pm.valid?
    assert_includes pm.errors[:name], "can't be blank"
  end

  test "should require locale" do
    pm = PaymentMethod.new(name: "Test")
    assert_not pm.valid?
    assert_includes pm.errors[:locale], "can't be blank"
  end

  test "should support identifier enum" do
    pm = payment_methods(:pix)
    assert pm.pix?

    pm2 = payment_methods(:credit_card)
    assert pm2.credit_card?
  end

  test "should soft delete" do
    pm = payment_methods(:credit_card)
    pm.soft_delete!
    assert pm.discarded?
    assert PaymentMethod.kept.where(id: pm.id).empty?
  end
end
