class AdminCategoriesController < ApplicationController
  before_action :set_category, only: [:update, :destroy]
  before_action :authenticate_user!
  before_action :authorize_admin!

  def index
    @categories = Category.includes(:links)
    @category = Category.new
    @category.links.build # Para el formulario anidado
  end

  def create
    @category = Category.new(category_params)

    if category_params_valid?
      if @category.save
        # Llama al trabajo de scraping después de guardar la categoría
        GenericScrapingJob.perform_later(@category.id)

        flash[:notice] = 'La categoría se creó con éxito y se inició el scraping.'
        redirect_to admin_categories_path
      else
        flash.now[:alert] = 'Error al crear la categoría. ' + @category.errors.full_messages.to_sentence
        render :index
      end
    else
      flash.now[:alert] = 'Al menos un enlace debe ser de "venex.com.ar" o "hardcorecomputacion.com".'
      render :index
    end
  end

  def update
    if @category.update(category_params)
      flash[:notice] = 'La categoría se actualizó con éxito.'
      redirect_to admin_categories_path
    else
      flash.now[:alert] = 'Error al actualizar la categoría. ' + @category.errors.full_messages.to_sentence
      render :edit
    end
  end

  def destroy
    @category.destroy
    flash[:notice] = 'La categoría se eliminó con éxito.'
    redirect_to admin_categories_path
  end

  private

  def authorize_admin!
    redirect_to root_path, alert: 'Acceso denegado' unless current_user.admin?
  end

  def set_category
    @category = Category.find(params[:id])
  end

  def category_params
    params.require(:category).permit(:name, links_attributes: [:url, :description])
  end

  # Método para validar los parámetros de la categoría
  def category_params_valid?
    links_attributes = params.dig(:category, :links_attributes)

    # Solo continúa si hay enlaces presentes
    return false unless links_attributes

    # Verifica si al menos uno de los enlaces tiene una URL válida
    links_attributes.values.any? { |link| valid_url?(link[:url]) }
  end

  # Método para validar la URL
  def valid_url?(url)
    # Define tus patrones de URL válidos
    valid_patterns = [
      /venex\.com\.ar/,
      /hardcorecomputacion\.com/
    ]
    
    valid_patterns.any? { |pattern| url =~ pattern }
  end
end
