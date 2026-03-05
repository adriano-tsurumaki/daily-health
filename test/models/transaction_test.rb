require "test_helper"

class TransactionTest < ActiveSupport::TestCase
  test "should require amount" do
    t = Transaction.new(payment_date: Date.current, transaction_type: :expense,
      user: users(:user_email_confirmed), payment_method: payment_methods(:pix))
    assert_not t.valid?
    assert_includes t.errors[:amount], "can't be blank"
  end

  test "should require payment_date" do
    t = Transaction.new(amount: 100, transaction_type: :expense,
      user: users(:user_email_confirmed), payment_method: payment_methods(:pix))
    assert_not t.valid?
    assert_includes t.errors[:payment_date], "can't be blank"
  end

  test "should support transaction_type enum" do
    t = transactions(:grocery_expense)
    assert t.expense?

    t2 = transactions(:salary_income)
    assert t2.income?
  end

  test "should support status enum" do
    t = transactions(:grocery_expense)
    assert t.paid?

    t2 = transactions(:pending_expense)
    assert t2.pending?
  end

  test "should have transaction items" do
    t = transactions(:grocery_expense)
    assert t.transaction_items.count >= 2
  end

  test "should have tags through transaction_tags" do
    t = transactions(:grocery_expense)
    assert t.tags.count >= 1
  end

  test "should soft delete" do
    t = transactions(:grocery_expense)
    t.soft_delete!
    assert t.discarded?
    assert Transaction.kept.where(id: t.id).empty?
  end

  test "should accept nested attributes for transaction_items" do
    t = Transaction.create!(
      amount: 100, payment_date: Date.current, transaction_type: :expense,
      status: :paid, user: users(:user_email_confirmed), payment_method: payment_methods(:pix),
      transaction_items_attributes: [
        { name: "Test Item", quantity: 1, unit_of_measure: "un", unit_price: 100 }
      ]
    )
    assert_equal 1, t.transaction_items.count
  end
end
