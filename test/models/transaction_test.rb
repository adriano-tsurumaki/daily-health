require "test_helper"

class TransactionTest < ActiveSupport::TestCase
  test "should require amount" do
    transaction = Transaction.new(
      description: "Teste",
      payment_date: Date.current,
      transaction_type: :expense,
      user: users(:user_email_confirmed),
      payment_method: payment_methods(:pix)
    )

    assert_not transaction.valid?
    assert_includes transaction.errors[:amount], "can't be blank"
  end

  test "should require description" do
    transaction = Transaction.new(
      amount: 100,
      payment_date: Date.current,
      transaction_type: :expense,
      user: users(:user_email_confirmed),
      payment_method: payment_methods(:pix)
    )

    assert_not transaction.valid?
    assert_includes transaction.errors[:description], "can't be blank"
  end

  test "should classify uncategorized transactions for review" do
    transaction = transactions(:uncategorized_expense)

    assert_equal "needs_category", transaction.review_status
  end

  test "credit card charge after closing should use next invoice bucket" do
    transaction = transactions(:pending_expense)

    assert_equal Finance::CommitmentRules.credit_card_due_date(
      transaction.payment_method,
      transaction.due_date
    ).strftime("%Y-%m"), transaction.period_bucket
  end

  test "should have transaction items" do
    transaction = transactions(:grocery_expense)

    assert transaction.transaction_items.count >= 2
  end

  test "should have tags through transaction_tags" do
    transaction = transactions(:grocery_expense)

    assert transaction.tags.count >= 1
  end

  test "should soft delete" do
    transaction = transactions(:grocery_expense)
    transaction.soft_delete!

    assert transaction.discarded?
    assert Transaction.kept.where(id: transaction.id).empty?
  end

  test "should accept nested attributes for transaction_items" do
    transaction = Transaction.create!(
      amount: 100,
      description: "Compra teste",
      payment_date: Date.current,
      due_date: Date.current,
      transaction_type: :expense,
      status: :paid,
      user: users(:user_email_confirmed),
      payment_method: payment_methods(:pix),
      transaction_items_attributes: [
        { name: "Test Item", quantity: 1, unit_of_measure: "un", unit_price: 100 }
      ]
    )

    assert_equal 1, transaction.transaction_items.count
  end
end
