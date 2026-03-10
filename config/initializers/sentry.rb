Sentry.init do |config|
  config.dsn = ENV["SENTRY_DSN"]
  config.breadcrumbs_logger = [ :active_support_logger, :http_logger ]
  config.release = File.read(Rails.root.join(".git_sha")).strip rescue "unknown"
  config.environment = Rails.env

  config.send_default_pii = true

  config.enable_logs = true
  config.enabled_patches = [ :logger ]

  config.traces_sample_rate = 0.1

  config.before_send_transaction = lambda do |event, _hint|
    return nil if event.transaction == "/up"
    event
  end
end if ENV["SENTRY_DSN"].present?
