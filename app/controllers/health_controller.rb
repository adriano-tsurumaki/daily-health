class HealthController < ApplicationController
  def show
    checks = {
      status: "ok",
      timestamp: Time.current.iso8601,
      version: (File.read(Rails.root.join(".git_sha")).strip rescue "unknown"),
      checks: {
        database: database_check,
        queue: queue_check,
        cache: cache_check
      }
    }

    status = checks[:checks].values.all? { |c| c[:status] == "ok" } ? :ok : :service_unavailable
    render json: checks, status: status
  end

  private

  def database_check
    ActiveRecord::Base.connection.execute("SELECT 1")
    { status: "ok" }
  rescue => e
    { status: "error", message: e.message }
  end

  def queue_check
    { status: "ok", pending_jobs: SolidQueue::Job.where(finished_at: nil).count }
  rescue => e
    { status: "error", message: e.message }
  end

  def cache_check
    Rails.cache.write("health_check", "ok", expires_in: 1.minute)
    { status: Rails.cache.read("health_check") == "ok" ? "ok" : "error" }
  rescue => e
    { status: "error", message: e.message }
  end
end
