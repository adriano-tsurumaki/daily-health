require "test_helper"

class AuthLoggingTest < ActionDispatch::IntegrationTest
  test "successful login logs auth_event with success" do
    output = capture_log_output do
      post user_session_path, params: {
        user: { email: "user_email_confirmed@example.com", password: "password123" }
      }, as: :json
    end

    assert_response :success

    log_entry = parse_lograge_line(output)
    assert_equal "login", log_entry["auth_event"]
    assert_equal true, log_entry["auth_success"]
    assert_includes log_entry["auth_email"], "*"
    assert_not_includes log_entry["auth_email"], "user_email_confirmed"
    assert log_entry["user_agent"].present? || log_entry["user_agent"].nil?
  end

  test "failed login logs auth_event with failure reason" do
    output = capture_log_output do
      post user_session_path, params: {
        user: { email: "user_email_confirmed@example.com", password: "wrongpassword" }
      }, as: :json
    end

    assert_response :unauthorized

    log_entry = parse_json_log_line(output)
    assert_equal "login", log_entry["auth_event"]
    assert_equal false, log_entry["auth_success"]
    assert log_entry["auth_failure"].present?
  end

  test "failed login with unconfirmed user logs unconfirmed reason" do
    output = capture_log_output do
      post user_session_path, params: {
        user: { email: "one@example.com", password: "password123" }
      }, as: :json
    end

    assert_response :unauthorized

    log_entry = parse_json_log_line(output)
    assert_equal "login", log_entry["auth_event"]
    assert_equal false, log_entry["auth_success"]
    assert_equal "unconfirmed", log_entry["auth_failure"]
  end

  test "successful registration logs auth_event" do
    output = capture_log_output do
      post user_registration_path, params: {
        user: {
          name: "Log Test",
          email: "logtest#{SecureRandom.hex(4)}@example.com",
          password: "password123",
          password_confirmation: "password123"
        }
      }, as: :json
    end

    assert_response :success

    log_entry = parse_lograge_line(output)
    assert_equal "registration", log_entry["auth_event"]
    assert_equal true, log_entry["auth_success"]
    assert_includes log_entry["auth_email"], "*"
  end

  test "failed registration logs validation errors" do
    output = capture_log_output do
      post user_registration_path, params: {
        user: { name: "", email: "bad", password: "short", password_confirmation: "mismatch" }
      }, as: :json
    end

    assert_response :unprocessable_content

    log_entry = parse_lograge_line(output)
    assert_equal "registration", log_entry["auth_event"]
    assert_equal false, log_entry["auth_success"]
    assert log_entry["auth_errors"].present?
  end

  test "mask_email hides email local part" do
    controller = Users::RegistrationsController.new
    masked = controller.send(:mask_email, "adriano@example.com")
    assert_equal "ad*****@example.com", masked
  end

  test "mask_email handles short emails" do
    controller = Users::RegistrationsController.new
    masked = controller.send(:mask_email, "ab@example.com")
    assert_equal "ab@example.com", masked
  end

  test "mask_email handles nil" do
    controller = Users::RegistrationsController.new
    assert_nil controller.send(:mask_email, nil)
  end

  private

  def capture_log_output(&block)
    io = StringIO.new
    new_logger = ActiveSupport::Logger.new(io)
    old_rails_logger = Rails.logger
    old_subscriber_logger = ActiveSupport::LogSubscriber.logger
    Rails.logger = new_logger
    ActiveSupport::LogSubscriber.logger = new_logger
    yield
    Rails.logger = old_rails_logger
    ActiveSupport::LogSubscriber.logger = old_subscriber_logger
    io.string
  end

  # Parses the Lograge JSON line (from process_action instrumentation)
  def parse_lograge_line(output)
    json_lines = output.lines.select { |l| l.strip.start_with?("{") }
    return {} if json_lines.empty?
    JSON.parse(json_lines.last)
  end

  # Parses any JSON log line containing auth_event (for CustomFailureApp logs)
  def parse_json_log_line(output)
    json_lines = output.lines.select { |l| l.strip.start_with?("{") && l.include?("auth_event") }
    return {} if json_lines.empty?
    JSON.parse(json_lines.last)
  end
end
