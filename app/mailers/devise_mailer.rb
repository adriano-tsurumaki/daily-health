class DeviseMailer < Devise::Mailer
  layout "mailer"

  protected

  def devise_mail(record, action, opts = {})
    I18n.with_locale(record.try(:locale) || I18n.default_locale) do
      super
    end
  end
end
