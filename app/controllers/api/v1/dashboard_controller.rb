class Api::V1::DashboardController < Api::BaseController
  def show
    month = (params[:month] || Date.current.month).to_i
    year = (params[:year] || Date.current.year).to_i

    render json: Finance::DashboardBuilder.new(
      user: current_user,
      month: month,
      year: year
    ).as_json
  end
end
