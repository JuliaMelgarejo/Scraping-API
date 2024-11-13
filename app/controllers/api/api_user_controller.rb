module Api
class ApiUserController < ApplicationController
protect_from_forgery with: :null_session
before_action :authenticate_request, only: [:subscription, :unsubscription, :mysubscriptions, :user_subscriptions]

    # POST /auth/register
    def register
      @user = User.new(user_params)
      if @user.save
        categories = Category.where(id: params[:category_ids])
        @user.categories << categories if categories.any?
        token = JsonWebToken.jwt_encode(user_id: @user.id)
        render json: { token: token, user: @user, subscribed_categories: categories }, status: :created
      else
        render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
      end
    end

    # POST /auth/login
    def login
      puts params.inspect 
      @user = User.find_by(email: params[:email])
      if @user&.valid_password?(params[:password])
        token = JsonWebToken.jwt_encode(user_id: @user.id)
        render json: { token: token, user: @user }, status: :ok
      else
        render json: { error: 'Invalid email or password' }, status: :unauthorized
      end
    end

    # GET /auth/user_subscriptions
    def user_subscriptions
      if @current_user.nil?
        return render json: { error: "Usuario no autenticado" }, status: :unauthorized
      end

      @categories = @current_user.categories

      ws_url = "ws://localhost:5000/cable"
      subscription_requests = @categories.map do |category|
        {
          category_id: category.id,
          url: "#{ws_url}?category_id=#{category.id}",
          request_body: {
            command: "subscribe",
            identifier: {
              channel: "NotificationsChannel"
            }.to_json
          }
        }
      end

      render json: {
        message: "Conexión a los canales WebSocket de suscripciones del usuario.",
        subscriptions: subscription_requests
      }, status: :ok
    end

    # PUT /auth/subscription
    def subscription
      if @current_user.nil?
        return render json: { error: "Usuario no autenticado" }, status: :unauthorized
      end
      category_ids = params[:category_ids]
      if category_ids.blank?
        return render json: { error: "No se proporcionaron categorías para suscribirse" }, status: :bad_request
      end
      categories = Category.where(id: category_ids)
      if categories.empty?
        return render json: { error: "Las categorías especificadas no existen" }, status: :not_found
      end

      already_subscribed_categories = @current_user.categories.where(id: category_ids)
      if already_subscribed_categories.any?
        return render json: { error: "Ya está suscrito a una o más categorías" }, status: :conflict
      end
      categories.each do |category|
        @current_user.subscriptions.find_or_create_by(category: category)
      end
      subscribed_categories = @current_user.categories.select(:id, :name, :created_at, :updated_at)
      render json: {subscribed_categories: subscribed_categories.as_json}, status: :ok
    end

    # DELETE /auth/subscription
    def unsubscription
      if @current_user.nil?
        return render json: { error: "Usuario no encontrado" }, status: :unauthorized
      end

      category_ids = params[:category_ids]
      if category_ids.blank?
        return render json: { error: "No se proporcionaron categorías para desuscribirse" }, status: :bad_request
      end

      categories_to_unsubscribe = @current_user.categories.where(id: category_ids)
      if categories_to_unsubscribe.empty?
        return render json: { error: "Las categorías especificadas no existen o no están suscritas" }, status: :not_found
      end

      @current_user.categories.delete(categories_to_unsubscribe)
      if @current_user.save
        render json: { message: "Categorías eliminadas con éxito", remaining_categories: @current_user.categories }, status: :ok
      else
        render json: { errors: @current_user.errors.full_messages }, status: :unprocessable_entity
      end
    end

      private
      def user_params
        params.require(:api_user).permit(:email, :password, :password_confirmation)
      end
end
end