class Users::RegistrationsController < Devise::RegistrationsController
  include AuthLoggable

  respond_to :json

  def update
    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)

    if resource.update_with_password(account_update_params)
      bypass_sign_in(resource, scope: resource_name)
      render json: { message: I18n.t("devise.registrations.updated") }, status: :ok
    else
      render json: { errors: resource.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    resource.destroy
    sign_out(resource_name)
    head :no_content
  end

  private

  def respond_with(resource, _opts = {})
    if resource.persisted?
      request.env["auth.event"]   = "registration"
      request.env["auth.success"] = true
      request.env["auth.email"]   = resource.email
      request.env["auth.user_id"] = resource.id
      head :ok
    else
      request.env["auth.event"]   = "registration"
      request.env["auth.success"] = false
      request.env["auth.email"]   = sign_up_params[:email]
      request.env["auth.errors"]  = resource.errors.full_messages.join("; ")
      render json: {
        status: { message: "User could not be created successfully." },
        errors: resource.errors.full_messages
      }, status: :unprocessable_content
    end
  end

  def sign_up_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

  def account_update_params
    params.require(:user).permit(:password, :password_confirmation, :current_password)
  end
end
