module Api
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
      header = request.headers['Authorization']
      Rails.logger.info "Authorization header received: #{header}"

      if header.nil?
        Rails.logger.warn "Authorization header missing"
        render json: { errors: 'Unauthorized' }, status: :unauthorized
        return
      end

      token = header.split(' ').last
      Rails.logger.debug "Extracted Token: #{token}"

      begin
        decoded = JsonWebToken.jwt_decode(token)
        Rails.logger.debug("Decoded Payload: #{decoded}")
        @current_user = User.find_by(id: decoded[:user_id])
        if @current_user.nil?
          Rails.logger.warn "User not found for ID: #{decoded[:user_id]}"
          render json: { errors: 'Unauthorized' }, status: :unauthorized
        end
      rescue ActiveRecord::RecordNotFound => e
        Rails.logger.error "ActiveRecord::RecordNotFound: #{e.message}"
        render json: { errors: 'Unauthorized' }, status: :unauthorized
      rescue JWT::DecodeError => e
        Rails.logger.error "JWT::DecodeError: #{e.message}"
        render json: { errors: 'Unauthorized' }, status: :unauthorized
      end
    end
  end
end
