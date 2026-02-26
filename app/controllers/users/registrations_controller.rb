class Users::RegistrationsController < Devise::RegistrationsController
  respond_to :json

  def destroy
    resource.destroy
    sign_out(resource_name)
    head :no_content
  end

  private

  def respond_with(resource, _opts = {})
    if resource.persisted?
      head :ok
    else
      render json: {
        status: { message: "User could not be created successfully." },
        errors: resource.errors.full_messages
      },  status: :unprocessable_content
    end
  end

  def sign_up_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end
