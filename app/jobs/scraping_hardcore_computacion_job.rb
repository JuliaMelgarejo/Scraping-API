class ScrapingHardcoreComputacionJob < ApplicationJob
    queue_as :default
    
    def perform(category_id)
      category = Category.find_by(id: category_id)
      return unless category # Salir si no se encuentra la categoría
      ScrapingHardcoreComputacion.new(category).scrape_links
    end
  end
  