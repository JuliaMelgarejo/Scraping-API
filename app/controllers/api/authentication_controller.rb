class Controller::Api::AuthenticationController < ApplicationController
  skip_before_action :authenticate_request, only: [:sign_in]

  # POST /auth/login
  def login
    @user = User.find_by(mail: params[:mail]) 
    if @user&.authenticate(params[:password])
      
      token = jwt_encode(user_id: @user.id)
      render json: { token: token }, status: :ok
    else
      render json: { error: 'Unauthorized' }, status: :unauthorized
    end
  end
end
