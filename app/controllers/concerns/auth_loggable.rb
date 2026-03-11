module AuthLoggable
  extend ActiveSupport::Concern

  private

  def append_info_to_payload(payload)
    super
    env = request.env

    return unless env["auth.event"].present?

    payload[:auth_event]   = env["auth.event"]
    payload[:auth_success] = env["auth.success"]
    payload[:auth_failure] = env["auth.failure_reason"]
    payload[:auth_email]   = mask_email(env["auth.email"])
    payload[:auth_user_id] = env["auth.user_id"]
    payload[:auth_errors]  = env["auth.errors"]
    payload[:user_agent]   = env["HTTP_USER_AGENT"]
  end

  def mask_email(email)
    return nil if email.blank?

    local, domain = email.split("@")
    return email if local.nil? || domain.nil?

    masked_local = local[0..1] + ("*" * [ local.length - 2, 0 ].max)
    "#{masked_local}@#{domain}"
  end
end
