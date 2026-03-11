class ApplicationController < ActionController::Base
  skip_before_action :verify_authenticity_token
  before_action :set_locale

  private

  def set_locale
    header = request.headers["Accept-Language"].to_s
    preferred = header.split(",").first&.split(";")&.first&.strip&.downcase
    I18n.locale = preferred&.start_with?("pt") ? :"pt-BR" : :en
  end
end
