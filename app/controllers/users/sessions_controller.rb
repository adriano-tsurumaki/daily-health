class Users::SessionsController < Devise::SessionsController
  include AuthLoggable

  respond_to :json

  private

  def respond_with(resource, _opts = {})
    head :ok
  end
end
