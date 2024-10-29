class AdminCategoriesController < ApplicationController
  before_action :set_category, only: [ :update, :destroy]
  before_action :authenticate_user!
  before_action :authorize_admin!

  def index
    @categories = Category.all.includes(:links)
    @category = Category.new
    @links = Link.all
  end

  def create
    @category = Category.new(category_params)
  
    if @category.save
      # Crear el link asociado si se seleccionó uno
      if params[:link_id].present?
        link = Link.find(params[:link_id])
        @category.links << link # Asocia el link a la categoría
      end
  
      redirect_to admin_categories_path, notice: 'Category was successfully created.'
    else
      render :index, alert: 'Failed to create category.'
    end
  end

  def update
    if @category.update(category_params)
      redirect_to admin_categories_path, notice: 'Category was successfully updated.'
    else
      render :edit, alert: 'Failed to update category.'
    end
  end

  def destroy
    @category.links.update_all(category_id: nil)
    @category.destroy
    redirect_to admin_categories_path, notice: 'Category was successfully deleted.'
  end

  private

  def authorize_admin!
    redirect_to root_path, alert: 'Access Denied' unless current_user.admin?
  end

  def set_category
    @category = Category.find(params[:id])
  end

  def category_params
    params.require(:category).permit(:name)
  end
end
