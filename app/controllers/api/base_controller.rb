class Api::BaseController < ApplicationController
  before_action :authenticate_user!
  after_action :sync_user_locale

  private

  def render_errors(record)
    render json: { errors: record.errors.full_messages }, status: :unprocessable_entity
  end

  def sync_user_locale
    return unless current_user
    detected = I18n.locale.to_s
    current_user.update_column(:locale, detected) if current_user.locale != detected
  end
end
