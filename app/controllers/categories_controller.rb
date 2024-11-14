class CategoriesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_category, only: %i[show edit update destroy]
  before_action :authorize_admin!, only: %i[show edit update destroy]

  def index
    current_user.admin!
    @categories = Category.all
  end

  def show
    @products = @category.products
  end

  def new
    @category = Category.new
  end

  def edit
  end

  def create
    @category = Category.new(category_params)
  
    if category_params_valid?
      # Realizamos la búsqueda sin tener en cuenta las mayúsculas y minúsculas
      existing_category = Category.find_by("LOWER(name) = ?", @category.name.downcase)
  
      if existing_category
        # Si existe, solo agregamos el nuevo enlace
        category_params[:links_attributes].each do |_, link_params|
          existing_category.links.create(url: link_params[:url], description: link_params[:description])
        end
        flash[:notice] = 'Categoría existente. Se agregó un nuevo enlace a la categoría.'
      else
        # Si no existe, creamos una nueva categoría con los enlaces
        if @category.save
          flash[:notice] = 'La categoría se creó con éxito y se inició el scraping.'
          GenericScrapingJob.perform_later(@category.id)
        else
          flash.now[:alert] = 'Error al crear la categoría. ' + @category.errors.full_messages.to_sentence
        end
      end
      
  end
  
  

    redirect_to categories_path
  end

  def update
    if @category.update(category_params)
      flash[:notice] = 'La categoría se actualizó con éxito.'
      redirect_to @category
    else
      flash.now[:alert] = 'Error al actualizar la categoría. ' + @category.errors.full_messages.to_sentence
      render :edit
    end
  end

  def destroy
    @category.destroy
    flash[:notice] = 'La categoría se eliminó con éxito.'
    redirect_to categories_path
  end

  private

  def set_category
    @category = Category.find(params[:id])
  end

  def authorize_admin!
    unless current_user.admin?
      redirect_to categories_path, alert: 'Acceso denegado. Solo administradores pueden acceder a esta sección.'
    end
  end

  def category_params
    params.require(:category).permit(:name, links_attributes: [:url, :description])
  end

  def scrape(category)
    links = category.links
    if links.empty?
      puts "No hay enlaces disponibles para la categoría #{category.id}."
      return
    end
    links.each do |link|
      puts "Scraping enlace: #{link.url}" 
      if link.url.include?("hardcorecomputacion")
        ScrapingHardcoreComputacion.new(category).scrape_links
      elsif link.url.include?("venex")
        ScrapingVenex.new(category).scrape_links
      else
        puts "No scraper available for URL: #{link.url}"
      end
    end
    puts "Scraping completado para la categoría #{category.id}."
  end
end
