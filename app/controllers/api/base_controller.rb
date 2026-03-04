class Api::BaseController < ApplicationController
  before_action :authenticate_user!

  private

  def render_errors(record)
    render json: { errors: record.errors.full_messages }, status: :unprocessable_entity
  end
end
