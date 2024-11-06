module Api
  class ApiUserController < ApplicationController
  protect_from_forgery with: :null_session
  before_action :authenticate_request, only: [:subscription, :unsubscription, :mysubscriptions, :user_subscriptions]

      # POST /auth/register
      def register
        # Crear un usuario y devolver un token con is_admin = false y las categorías suscritas
        @user = User.new(user_params) # Define el rol predeterminado como usuario
        if @user.save
          # Relacionar el usuario con las categorías proporcionadas
          categories = Category.where(id: params[:category_ids])
          @user.categories << categories if categories.any?
          # Generar el token JWT
          token = JsonWebToken.jwt_encode(user_id: @user.id)
          render json: { token: token, user: @user, subscribed_categories: categories }, status: :created
        else
          render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # POST /auth/login
      def login
        puts params.inspect # Esta línea imprime los parámetros en la consola del servidor
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
        # Verificamos que @current_user esté asignado después de la autenticación
        if @current_user.nil?
          return render json: { error: "Usuario no autenticado" }, status: :unauthorized
        end
      
        
        # Obtener las categorías a las que el usuario está suscrito
        subscribed_categories = @current_user.categories
      
        render json: { subscribed_categories: subscribed_categories }, status: :ok
      end

     # PUT /auth/subscription
    def subscription
      # Verificamos que @current_user esté asignado después de la autenticación
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

      # Crear o actualizar las suscripciones del usuario actual
      categories.each do |category|
        @current_user.subscriptions.find_or_create_by(category: category)
      end

      # WebSocket URL para suscripciones (ahora en localhost:5000)
      ws_url = "ws://localhost:5000/cable"
      subscription_requests = categories.map do |category|
        {
          category_id: category.id,
          request_body: {
            command: "subscribe",
            identifier: {
              channel: "NotificationsChannel",
              category_id: category.id
            }.to_json
          }
        }
      end

      # Responder con mensaje de éxito y detalles de las categorías suscritas
      render json: {
        message: "Suscripción actualizada con éxito",
        websocket_url: ws_url,
        subscriptions: subscription_requests,
        subscribed_categories: @current_user.categories
      }, status: :ok
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

    # GET /auth/mysubscriptions
    def mysubscriptions
      if @current_user.nil?
        return render json: { error: "Usuario no autenticado" }, status: :unauthorized
      end

      @categories = @current_user.categories

      ws_url = "ws://localhost:3000/cable"
      subscription_requests = @categories.map do |category|
        {
          category_id: category.id,
          request_body: {
            command: "subscribe",
            identifier: {
              channel: "SubscriptionsChannel",
              room: category.id
            }.to_json
          }
        }
      end

      render json: {
        message: "Conexión a los canales WebSocket de suscripciones del usuario.",
        websocket_url: ws_url,
        subscriptions: subscription_requests
      }, status: :ok
    end



      private

      def user_params
        params.require(:api_user).permit(:email, :password, :password_confirmation)
      end
      
      
    
  end
end