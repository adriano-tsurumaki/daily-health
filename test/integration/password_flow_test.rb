require "test_helper"

class PasswordFlowTest < ActionDispatch::IntegrationTest
  # === Password Reset (forgot password) ===

  test "request password reset with valid email returns 200" do
    post user_password_path, params: {
      user: { email: users(:user_email_confirmed).email }
    }, as: :json

    assert_response :ok
    assert json_response["message"].present?
  end

  test "request password reset with unknown email returns 422" do
    post user_password_path, params: {
      user: { email: "nonexistent@example.com" }
    }, as: :json

    assert_response :unprocessable_entity
  end

  test "reset password with valid token succeeds" do
    user = users(:user_email_confirmed)
    token = user.send_reset_password_instructions

    put user_password_path, params: {
      user: {
        reset_password_token: token,
        password: "newpassword123",
        password_confirmation: "newpassword123"
      }
    }, as: :json

    assert_response :ok
    assert json_response["message"].present?
  end

  test "reset password with invalid token returns 422" do
    put user_password_path, params: {
      user: {
        reset_password_token: "invalid_token",
        password: "newpassword123",
        password_confirmation: "newpassword123"
      }
    }, as: :json

    assert_response :unprocessable_entity
    assert json_response["errors"].present?
  end

  test "reset password with mismatched confirmation returns 422" do
    user = users(:user_email_confirmed)
    token = user.send_reset_password_instructions

    put user_password_path, params: {
      user: {
        reset_password_token: token,
        password: "newpassword123",
        password_confirmation: "differentpassword"
      }
    }, as: :json

    assert_response :unprocessable_entity
  end

  # === Change Password (authenticated) ===

  test "change password with correct current_password succeeds" do
    user = users(:user_email_confirmed)
    sign_in user

    put user_registration_path, params: {
      user: {
        current_password: "password123",
        password: "newpassword456",
        password_confirmation: "newpassword456"
      }
    }, as: :json

    assert_response :ok
    assert json_response["message"].present?
  end

  test "change password with wrong current_password returns 422" do
    user = users(:user_email_confirmed)
    sign_in user

    put user_registration_path, params: {
      user: {
        current_password: "wrongpassword",
        password: "newpassword456",
        password_confirmation: "newpassword456"
      }
    }, as: :json

    assert_response :unprocessable_entity
    assert json_response["errors"].present?
  end

  # === Email Confirmation ===

  test "confirmation with valid token renders HTML success page" do
    user = users(:user)
    token = user.confirmation_token

    get user_confirmation_path(confirmation_token: token)

    assert_response :ok
    assert_includes response.body, "Daily Health"
    assert_includes response.body, "<!DOCTYPE html>"
  end

  test "confirmation with invalid token renders HTML error page" do
    get user_confirmation_path(confirmation_token: "invalid_token")

    assert_response :ok
    assert_includes response.body, "<!DOCTYPE html>"
  end

  # === i18n ===

  test "password reset respects Accept-Language pt-BR" do
    post user_password_path, params: {
      user: { email: users(:user_email_confirmed).email }
    }, headers: { "Accept-Language" => "pt-BR" }, as: :json

    assert_response :ok
    assert json_response["message"].present?
  end
end
