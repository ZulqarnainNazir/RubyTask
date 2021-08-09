class AuthenticationController < ApplicationController
  skip_before_action :authenticate_request

  def login
    command = AuthenticateUser.new(params[:email], params[:password]).call

    if command.successful?
      render(json: { auth_token: command.result })
    else
      render(json: { error: command.errors }, status: :unauthorized)
    end
  end
end
