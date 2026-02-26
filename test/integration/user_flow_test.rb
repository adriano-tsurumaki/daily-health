require "test_helper"

class UserFlowTest < ActionDispatch::IntegrationTest
  test "should register a new user successfully" do
    post user_registration_path, params: {
      user: {
        name: "Test",
        email: "test@example.com",
        password: "password123",
        password_confirmation: "password123"
      }
    }, as: :json
    assert_response :success
  end

  test "should return error when registering with an email already taken" do
    params = {
      user: {
        name: "New User",
        email: "new@example.com",
        password: "password123",
        password_confirmation: "password123"
      }
    }

    post user_registration_path, params: params, as: :json
    assert_response :success

    post user_registration_path, params: params, as: :json
    assert_response :unprocessable_content

    assert_equal "User could not be created successfully.", json_response.dig("status", "message")
    assert_includes json_response["errors"], "Email has already been taken"
  end

  test "should return JWT token when signing in with a confirmed email" do
    post user_session_path, params: {
      user: {
        email: "user_email_confirmed@example.com",
        password: "password123"
      }
    }, as: :json
    assert_response :success

    assert_not_nil response.headers["Authorization"]
  end

  test "should return error when signing in with an unconfirmed email" do
    post user_session_path, params: {
      user: {
        email: "one@example.com",
        password: "password123"
      }
    }, as: :json
    assert_response :unauthorized
  end

  test "should logout successfully" do
    token = sign_in_confirmed_user

    delete destroy_user_session_path, headers: { "Authorization" => token }, as: :json
    assert_response :no_content

    # Token deve estar no JwtDenylist após logout
    delete user_registration_path, headers: { "Authorization" => token }, as: :json
    assert_response :unauthorized
  end

  test "should delete account when authenticated" do
    token = sign_in_confirmed_user

    delete user_registration_path, headers: { "Authorization" => token }, as: :json
    assert_response :no_content

    assert_nil User.find_by(email: "user_email_confirmed@example.com")
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
