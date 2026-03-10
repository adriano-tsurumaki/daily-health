class Users::RegistrationsController < Devise::RegistrationsController
  include AuthLoggable

  respond_to :json

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
end
