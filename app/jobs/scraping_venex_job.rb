
class ScrapingVenexJob < ApplicationJob
    queue_as :default
  
    def perform(category_id)
      category = Category.find_by(id: category_id)
      return unless category # Salir si no se encuentra la categoría
  
      scraper = ScrapingVenex.new(category)
      scraper.scrape_links
    end
  end
  