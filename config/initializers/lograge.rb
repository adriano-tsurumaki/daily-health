Rails.application.configure do
  config.lograge.enabled = true
  config.lograge.formatter = Lograge::Formatters::Json.new

  mask_email = ->(email) {
    return nil if email.blank?
    local, domain = email.split("@")
    next email if local.nil? || domain.nil?
    "#{local[0..1]}#{"*" * [ local.length - 2, 0 ].max}@#{domain}"
  }

  config.lograge.custom_options = lambda do |event|
    payload = event.payload

    options = {
      request_id: payload[:request_id],
      user_id: payload[:user_id] || payload[:auth_user_id],
      ip: payload[:ip],
      host: payload[:host],
      time: Time.current.iso8601
    }

    if payload[:auth_event].present?
      options[:auth_event]   = payload[:auth_event]
      options[:auth_success] = payload[:auth_success]
      options[:auth_email]   = payload[:auth_email]
      options[:auth_failure] = payload[:auth_failure] if payload[:auth_failure].present?
      options[:auth_errors]  = payload[:auth_errors] if payload[:auth_errors].present?
      options[:user_agent]   = payload[:user_agent]
    end

    options.compact
  end

  config.lograge.ignore_actions = [ "HealthController#show", "Rails::HealthController#show" ]

  config.lograge.custom_payload do |controller|
    env = controller.request.env

    base = {
      request_id: controller.request.request_id,
      user_id: controller.respond_to?(:current_user, true) ? controller.current_user&.id : nil,
      ip: controller.request.remote_ip,
      host: controller.request.host
    }

    if env["auth.event"].present?
      base[:auth_event]   = env["auth.event"]
      base[:auth_success] = env["auth.success"]
      base[:auth_email]   = mask_email.call(env["auth.email"])
      base[:auth_failure] = env["auth.failure_reason"]
      base[:auth_user_id] = env["auth.user_id"]
      base[:auth_errors]  = env["auth.errors"]
      base[:user_agent]   = env["HTTP_USER_AGENT"]
    end

    base.compact
  end
end
