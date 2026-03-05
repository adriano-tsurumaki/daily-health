require "test_helper"

class FinanceFlowTest < ActionDispatch::IntegrationTest
  # === Authentication ===

  test "should return 401 without token on transactions" do
    get api_v1_transactions_path, as: :json
    assert_response :unauthorized
  end

  # === Transactions CRUD ===

  test "should list transactions for current month" do
    token = sign_in_confirmed_user

    get api_v1_transactions_path, headers: { "Authorization" => token }, as: :json
    assert_response :success
    assert_kind_of Array, json_response
  end

  test "should filter transactions by month and year" do
    token = sign_in_confirmed_user
    month = Date.current.month
    year = Date.current.year

    get api_v1_transactions_path, params: { month: month, year: year },
      headers: { "Authorization" => token }, as: :json
    assert_response :success
    assert json_response.length >= 1
  end

  test "should show a transaction" do
    token = sign_in_confirmed_user
    transaction = transactions(:grocery_expense)

    get api_v1_transaction_path(transaction), headers: { "Authorization" => token }, as: :json
    assert_response :success
    assert_equal transaction.id, json_response["id"]
    assert json_response.key?("transaction_items")
    assert json_response.key?("tags")
  end

  test "should create a transaction" do
    token = sign_in_confirmed_user
    pm = payment_methods(:pix)

    assert_difference "Transaction.count", 1 do
      post api_v1_transactions_path, params: {
        transaction: {
          amount: 99.90,
          payment_date: Date.current,
          transaction_type: "expense",
          status: "paid",
          payment_method_id: pm.id
        }
      }, headers: { "Authorization" => token }, as: :json
    end
    assert_response :created
    assert_equal 99.9, json_response["amount"].to_f
  end

  test "should create a transaction with items" do
    token = sign_in_confirmed_user
    pm = payment_methods(:pix)

    post api_v1_transactions_path, params: {
      transaction: {
        amount: 50.00,
        payment_date: Date.current,
        transaction_type: "expense",
        status: "paid",
        payment_method_id: pm.id,
        transaction_items_attributes: [
          { name: "Item A", quantity: 2, unit_of_measure: "un", unit_price: 25.00 }
        ]
      }
    }, headers: { "Authorization" => token }, as: :json
    assert_response :created
    assert_equal 1, json_response["transaction_items"].length
  end

  test "should create a transaction with tags" do
    token = sign_in_confirmed_user
    pm = payment_methods(:pix)
    tag = tags(:essential)

    post api_v1_transactions_path, params: {
      transaction: {
        amount: 30.00,
        payment_date: Date.current,
        transaction_type: "expense",
        status: "paid",
        payment_method_id: pm.id,
        tag_ids: [ tag.id ]
      }
    }, headers: { "Authorization" => token }, as: :json
    assert_response :created
    assert_equal 1, json_response["tags"].length
  end

  test "should update a transaction" do
    token = sign_in_confirmed_user
    transaction = transactions(:grocery_expense)

    patch api_v1_transaction_path(transaction), params: {
      transaction: { amount: 200.00 }
    }, headers: { "Authorization" => token }, as: :json
    assert_response :success
    assert_equal 200.0, json_response["amount"].to_f
  end

  test "should destroy a transaction with soft delete" do
    token = sign_in_confirmed_user
    transaction = transactions(:grocery_expense)

    delete api_v1_transaction_path(transaction), headers: { "Authorization" => token }, as: :json
    assert_response :no_content
    assert transaction.reload.discarded?
  end

  test "should not access another user's transaction" do
    token = sign_in_confirmed_user
    # Create a transaction for a different user
    other_user = users(:user)
    pm = payment_methods(:pix)
    other_transaction = Transaction.create!(
      amount: 100, payment_date: Date.current, transaction_type: :expense,
      status: :paid, user: other_user, payment_method: pm
    )

    get api_v1_transaction_path(other_transaction), headers: { "Authorization" => token }, as: :json
    assert_response :not_found
  end

  # === Categories CRUD ===

  test "should list categories" do
    token = sign_in_confirmed_user

    get api_v1_categories_path, headers: { "Authorization" => token }, as: :json
    assert_response :success
    assert_kind_of Array, json_response
    assert json_response.length >= 2
  end

  test "should create a category" do
    token = sign_in_confirmed_user

    assert_difference "Category.count", 1 do
      post api_v1_categories_path, params: {
        category: { name: "Saúde" }
      }, headers: { "Authorization" => token }, as: :json
    end
    assert_response :created
    assert_equal "Saúde", json_response["name"]
  end

  test "should update a category" do
    token = sign_in_confirmed_user
    category = categories(:food_category)

    patch api_v1_category_path(category), params: {
      category: { name: "Alimentação e Bebidas" }
    }, headers: { "Authorization" => token }, as: :json
    assert_response :success
    assert_equal "Alimentação e Bebidas", json_response["name"]
  end

  test "should destroy a category with soft delete" do
    token = sign_in_confirmed_user
    category = categories(:food_category)

    delete api_v1_category_path(category), headers: { "Authorization" => token }, as: :json
    assert_response :no_content
    assert category.reload.discarded?
  end

  # === Tags CRUD ===

  test "should list tags" do
    token = sign_in_confirmed_user

    get api_v1_tags_path, headers: { "Authorization" => token }, as: :json
    assert_response :success
    assert_kind_of Array, json_response
    assert json_response.length >= 2
  end

  test "should create a tag" do
    token = sign_in_confirmed_user

    assert_difference "Tag.count", 1 do
      post api_v1_tags_path, params: {
        tag: { name: "Investimento" }
      }, headers: { "Authorization" => token }, as: :json
    end
    assert_response :created
    assert_equal "Investimento", json_response["name"]
  end

  test "should not create duplicate tag" do
    token = sign_in_confirmed_user

    post api_v1_tags_path, params: {
      tag: { name: "Essencial" }
    }, headers: { "Authorization" => token }, as: :json
    assert_response :unprocessable_entity
  end

  test "should update a tag" do
    token = sign_in_confirmed_user
    tag = tags(:leisure)

    patch api_v1_tag_path(tag), params: {
      tag: { name: "Diversão" }
    }, headers: { "Authorization" => token }, as: :json
    assert_response :success
    assert_equal "Diversão", json_response["name"]
  end

  test "should destroy a tag with soft delete" do
    token = sign_in_confirmed_user
    tag = tags(:leisure)

    delete api_v1_tag_path(tag), headers: { "Authorization" => token }, as: :json
    assert_response :no_content
    assert tag.reload.discarded?
  end

  # === Payment Methods CRUD ===

  test "should list payment methods" do
    token = sign_in_confirmed_user

    get api_v1_payment_methods_path, headers: { "Authorization" => token }, as: :json
    assert_response :success
    assert_kind_of Array, json_response
    assert json_response.length >= 2
  end

  test "should create a payment method" do
    token = sign_in_confirmed_user

    assert_difference "PaymentMethod.count", 1 do
      post api_v1_payment_methods_path, params: {
        payment_method: { name: "Boleto", locale: "pt_BR", identifier: "boleto" }
      }, headers: { "Authorization" => token }, as: :json
    end
    assert_response :created
    assert_equal "Boleto", json_response["name"]
  end

  test "should update a payment method" do
    token = sign_in_confirmed_user
    pm = payment_methods(:credit_card)

    patch api_v1_payment_method_path(pm), params: {
      payment_method: { name: "Cartão Visa" }
    }, headers: { "Authorization" => token }, as: :json
    assert_response :success
    assert_equal "Cartão Visa", json_response["name"]
  end

  test "should destroy a payment method with soft delete" do
    token = sign_in_confirmed_user
    pm = payment_methods(:credit_card)

    delete api_v1_payment_method_path(pm), headers: { "Authorization" => token }, as: :json
    assert_response :no_content
    assert pm.reload.discarded?
  end

  # === Dashboard ===

  test "should return dashboard summary" do
    token = sign_in_confirmed_user

    get api_v1_dashboard_path, headers: { "Authorization" => token }, as: :json
    assert_response :success
    assert json_response.key?("total_income")
    assert json_response.key?("total_expense")
    assert json_response.key?("balance")
    assert json_response.key?("recent_transactions")
  end

  private

  def sign_in_confirmed_user
    post user_session_path, params: {
      user: {
        email: "user_email_confirmed@example.com",
        password: "password123"
      }
    }, as: :json
    response.headers["Authorization"]
  end
end
