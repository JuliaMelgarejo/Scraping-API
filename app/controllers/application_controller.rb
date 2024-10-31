class ApplicationController < ActionController::API
  include JsonWebToken

  before_action :authenticate_request

  skip_before_action :authenticate_request, if: :devise_controller?


  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:mail, :password, :password_confirmation])
  end

  private

    def authenticate_request
      token = request.headers['Authorization']&.split(' ')&.last
      if token.nil?
        render json: { error: 'Token no proporcionado' }, status: :unauthorized
        return
      end

      decoded_token = jwt_decode(token)
      if decoded_token && decoded_token[:user_id]
        @current_user = User.find(decoded_token[:user_id])
      else
        render json: { error: 'Token inválido' }, status: :unauthorized
      end
    end
  
end
