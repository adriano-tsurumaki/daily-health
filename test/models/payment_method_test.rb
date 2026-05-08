require "test_helper"

class PaymentMethodTest < ActiveSupport::TestCase
  test "should require name" do
    payment_method = PaymentMethod.new(locale: "pt-BR", kind: :account)

    assert_not payment_method.valid?
    assert_includes payment_method.errors[:name], "can't be blank"
  end

  test "should require card schedule fields for credit cards" do
    payment_method = PaymentMethod.new(
      name: "Cartão",
      locale: "pt-BR",
      kind: :credit_card,
      display_color: "#1d4ed8"
    )

    assert_not payment_method.valid?
    assert payment_method.errors[:closing_day].present?
    assert payment_method.errors[:due_day].present?
    assert payment_method.errors[:credit_limit].present?
  end

  test "should expose identifier and kind enums without conflict" do
    instant_method = payment_methods(:pix)
    card_method = payment_methods(:credit_card)

    assert instant_method.identifier_pix?
    assert instant_method.instant?
    assert card_method.identifier_credit_card?
    assert card_method.credit_card?
  end

  test "should soft delete" do
    payment_method = payment_methods(:credit_card)
    payment_method.soft_delete!

    assert payment_method.discarded?
    assert PaymentMethod.kept.where(id: payment_method.id).empty?
  end
end
