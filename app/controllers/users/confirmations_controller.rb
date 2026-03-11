class Users::ConfirmationsController < Devise::ConfirmationsController
  def show
    self.resource = resource_class.confirm_by_token(params[:confirmation_token])

    if resource.errors.empty?
      @confirmed = true
      locale = resource.locale.presence || I18n.locale.to_s
    else
      @confirmed = false
      @error_messages = resource.errors.full_messages
      locale = I18n.locale.to_s
    end

    I18n.with_locale(locale) do
      render layout: false
    end
  end
end
