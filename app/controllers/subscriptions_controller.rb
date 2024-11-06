class SubscriptionsController < ApplicationController
  before_action :authenticate_user! # Asegúrate de que el usuario esté autenticado
  before_action :set_subscription, only: %i[show edit update destroy]

  # GET /subscriptions or /subscriptions.json
  def index
    @subscriptions = current_user.subscriptions.includes(:category) # Carga las suscripciones del usuario
  end

  # GET /subscriptions/1 or /subscriptions/1.json
  def show
  end

  # GET /subscriptions/new
  def new
    @subscription = Subscription.new
  end

  # GET /subscriptions/1/edit
  def edit
  end

  # POST /subscriptions or /subscriptions.json
  def create
    @subscription = current_user.subscriptions.new(subscription_params) # Asocia la suscripción al usuario actual
  
    respond_to do |format|
      if @subscription.save
        format.html { redirect_to subscriptions_path, notice: "Te has suscrito a la categoría." }
      else
        format.html { render :new, status: :unprocessable_entity }
        Rails.logger.debug @subscription.errors.full_messages # Para ver errores en el log
      end
    end
  end

  # PATCH/PUT /subscriptions/1 or /subscriptions/1.json
  def update
    respond_to do |format|
      if @subscription.update(subscription_params)
        format.html { redirect_to @subscription, notice: "Subscription was successfully updated." }
        format.json { render :show, status: :ok, location: @subscription }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @subscription.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /subscriptions/1 or /subscriptions/1.json
  def destroy
    @subscription.destroy

    respond_to do |format|
      format.html { redirect_to subscriptions_path, status: :see_other, notice: "Te has desuscrito de la categoría." }
      format.json { head :no_content }
    end
  end

  # Método para realizar la suscripción
  def subscribe
    category = Category.find(params[:id])

    # Verificar si el usuario ya está suscrito a la categoría
    if current_user.subscriptions.exists?(category: category)
      flash[:alert] = "Ya estás suscrito a esta categoría."
    else
      # Crear la suscripción
      current_user.subscriptions.create!(category: category)
      flash[:notice] = "Te has suscrito a la categoría #{category.name}."
    end

    redirect_to categories_path  # Redireccionar a la página principal de categorías
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_subscription
    @subscription = current_user.subscriptions.find(params[:id]) # Busca la suscripción del usuario actual
  end

  # Only allow a list of trusted parameters through.
  def subscription_params
    params.require(:subscription).permit(:category_id) # Permite solo el category_id
  end
end
