require "test_helper"

class FinanceFlowTest < ActionDispatch::IntegrationTest
  test "should return 401 without token on transactions" do
    get api_v1_transactions_path, as: :json

    assert_response :unauthorized
  end

  test "should list transactions using commitment bucket" do
    token = sign_in_confirmed_user

    get api_v1_transactions_path,
      params: { month: Date.current.month, year: Date.current.year },
      headers: { "Authorization" => token },
      as: :json

    assert_response :success
    assert_kind_of Array, json_response
    assert json_response.all? { |entry| entry.key?("period_bucket") }
  end

  test "should create a transaction with new descriptive fields" do
    token = sign_in_confirmed_user
    payment_method = payment_methods(:pix)

    assert_difference "Transaction.count", 1 do
      post api_v1_transactions_path, params: {
        transaction: {
          amount: 99.90,
          description: "Farmacia do mes",
          merchant_name: "Drogaria Central",
          payment_date: Date.current,
          due_date: Date.current,
          transaction_type: "expense",
          status: "paid",
          payment_method_id: payment_method.id
        }
      }, headers: { "Authorization" => token }, as: :json
    end

    assert_response :created
    assert_equal "Farmacia do mes", json_response["description"]
    assert_equal "paid", json_response["status"]
  end

  test "should create installment plan and future transactions" do
    token = sign_in_confirmed_user
    payment_method = payment_methods(:credit_card)

    assert_difference "InstallmentPlan.count", 1 do
      assert_difference "Transaction.count", 3 do
        post api_v1_transactions_path, params: {
          transaction: {
            amount: 900.00,
            description: "Notebook",
            payment_date: Date.current,
            due_date: Date.current,
            transaction_type: "expense",
            status: "paid",
            payment_method_id: payment_method.id,
            installment_plan_attributes: {
              name: "Notebook 3x",
              total_installments: 3,
              interval_in_months: 1
            }
          }
        }, headers: { "Authorization" => token }, as: :json
      end
    end

    assert_response :created
    assert_equal 3, json_response.dig("installment_plan", "total_installments")
    assert_equal 1, json_response.dig("installment_plan", "current_installment")
  end

  test "credit card transaction after closing should return future commitment bucket" do
    token = sign_in_confirmed_user
    transaction = transactions(:pending_expense)

    get api_v1_transaction_path(transaction), headers: { "Authorization" => token }, as: :json

    assert_response :success
    expected_bucket = Finance::CommitmentRules.credit_card_due_date(
      transaction.payment_method,
      transaction.due_date
    ).strftime("%Y-%m")
    assert_equal expected_bucket, json_response["period_bucket"]
  end

  test "should list and create recurrences" do
    token = sign_in_confirmed_user

    get api_v1_recurrences_path, headers: { "Authorization" => token }, as: :json
    assert_response :success
    assert json_response.length >= 2

    assert_difference "Recurrence.count", 1 do
      post api_v1_recurrences_path, params: {
        recurrence: {
          name: "Streaming",
          amount: 49.90,
          frequency: "monthly",
          recurrence_interval: 1,
          next_due_date: Date.current,
          payment_method_id: payment_methods(:checking_account).id,
          category_id: categories(:transport_category).id,
          is_active: true
        }
      }, headers: { "Authorization" => token }, as: :json
    end

    assert_response :created
    assert_equal "Streaming", json_response["name"]
    assert json_response.key?("projection")
  end

  test "dashboard should return separated blocks" do
    token = sign_in_confirmed_user

    get api_v1_dashboard_path, headers: { "Authorization" => token }, as: :json

    assert_response :success
    assert json_response.key?("summary")
    assert json_response.key?("alerts")
    assert json_response.key?("review_queue")
    assert json_response.key?("instrument_snapshots")
    assert json_response.key?("upcoming_timeline")
    assert json_response.key?("budget_health")
    assert json_response.key?("rankings")
    assert json_response.key?("recent_activity")
  end

  test "dashboard should flag uncategorized entries in review queue" do
    token = sign_in_confirmed_user

    get api_v1_dashboard_path, headers: { "Authorization" => token }, as: :json

    assert_response :success
    assert_operator json_response.dig("review_queue", "uncategorized_count"), :>=, 1
    labels = json_response.fetch("budget_health").map { |entry| entry["label"] }
    assert_includes labels, "Sem categoria"
  end

  test "dashboard should project recurrence without duplicating realized launch" do
    token = sign_in_confirmed_user

    get api_v1_dashboard_path, headers: { "Authorization" => token }, as: :json

    assert_response :success
    titles = json_response.fetch("upcoming_timeline").map { |entry| entry["title"] }
    assert_includes titles, "Internet"
    assert_equal 1, titles.count { |title| title == "Academia" }
  end

  test "should not access another user's transaction" do
    token = sign_in_confirmed_user
    other_user = users(:user)
    payment_method = payment_methods(:pix)

    other_transaction = Transaction.create!(
      amount: 100,
      description: "Outro usuario",
      payment_date: Date.current,
      due_date: Date.current,
      transaction_type: :expense,
      status: :paid,
      user: other_user,
      payment_method: payment_method
    )

    get api_v1_transaction_path(other_transaction), headers: { "Authorization" => token }, as: :json

    assert_response :not_found
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
