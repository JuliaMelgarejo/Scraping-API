class ApplicationController < ActionController::Base
  include JsonWebToken

  def authenticate_request
    header = request.headers["Authorization"]
    header = header.split(" ").last if header
    begin
      @decoded = JsonWebToken.jwt_decode(header)
      @current_user = User.find(@decoded[:user_id])
      puts '-'*30
      p @current_user.email
      Rails.logger.info "Datos recibidos: #{@current_user.email}"
    rescue ActiveRecord::RecordNotFound => e
      render json: { errors: e.message }, status: :unauthorized
    rescue JWT::DecodeError => e
      render json: { errors: e.message }, status: :unauthorized
    end
  end

end