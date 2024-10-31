class CategoriesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_category, only: %i[show edit update destroy]
  before_action :authorize_admin!, only: %i[show edit update destroy]

  # GET /categories or /categories.json
  def index
    @categories = Category.all
  end

  # GET /categories/1 or /categories/1.json
  def show
    @products = @category.products
  end

  # GET /categories/new
  def new
    @category = Category.new
  end

  # GET /categories/1/edit
  def edit
  end
  
  # POST /categories or /categories.json
  def create
    @category = Category.new(category_params)

    respond_to do |format|
      if @category.save
        scrape(@category) # Llamar al método de scraping después de crear la categoría
        format.html { redirect_to @category, notice: "Category was successfully created." }
        format.json { render :show, status: :created, location: @category }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @category.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /categories/1 or /categories/1.json
  def update
    respond_to do |format|
      if @category.update(category_params)
        format.html { redirect_to @category, notice: "Category was successfully updated." }
        format.json { render :show, status: :ok, location: @category }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @category.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /categories/1 or /categories/1.json
  def destroy
    @category.destroy

    respond_to do |format|
      format.html { redirect_to categories_path, status: :see_other, notice: "Category was successfully destroyed." }
      format.json { head :no_content }
    end
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
    params.require(:category).permit(:name)
  end

  # Método para realizar el scraping
  def scrape(category)
    links = category.links

    if links.empty?
      puts "No hay enlaces disponibles para la categoría #{category.id}."
      return
    end

    links.each do |link|
      puts "Scraping enlace: #{link.url}" # Mensaje de depuración
      if link.url.include?("hardcorecomputacion")
        ScrapingHardcoreComputacion.new(category).scrape_links
      elsif link.url.include?("venex")
        ScrapingVenex.new(category).scrape_links
      else
        puts "No scraper available for URL: #{link.url}"
      end
    end

    puts "Scraping completado para la categoría #{category.id}." # Mensaje de finalización
  end
end
