class CustomFailureApp < Devise::FailureApp
  def respond
    log_auth_failure
    super
  end

  private

  def log_auth_failure
    email = request.params.dig("user", "email")

    payload = {
      auth_event: "login",
      auth_success: false,
      auth_failure: failure_reason,
      auth_email: mask_email(email),
      user_agent: request.user_agent,
      ip: request.remote_ip,
      request_id: request.request_id,
      time: Time.current.iso8601,
      status: 401
    }.compact

    Rails.logger.info(payload.to_json)
  end

  def failure_reason
    case warden_message
    when :unconfirmed then "unconfirmed"
    when :invalid     then "invalid_credentials"
    when :not_found_in_database then "not_found"
    when :locked      then "locked"
    else warden_message.to_s
    end
  end

  def mask_email(email)
    return nil if email.blank?

    local, domain = email.split("@")
    return email if local.nil? || domain.nil?

    masked_local = local[0..1] + ("*" * [ local.length - 2, 0 ].max)
    "#{masked_local}@#{domain}"
  end
end
