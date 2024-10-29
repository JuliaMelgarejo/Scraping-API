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
    
    if @category.save
      flash[:notice] = 'La categoría se creó con éxito.'
      redirect_to admin_categories_path
    else
      flash.now[:alert] = 'Error al crear la categoría.'
      render :index
    end
  end

  def update
    if @category.update(category_params)
      flash[:notice] = 'La categoría se actualizó con éxito.'
      redirect_to admin_categories_path
    else
      flash.now[:alert] = 'Error al actualizar la categoría.'
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
end
