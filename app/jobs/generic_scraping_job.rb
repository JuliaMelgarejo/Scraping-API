
class GenericScrapingJob < ApplicationJob
  queue_as :default

  VALID_URLS = [
    /venex\.com\.ar/,
    /hardcorecomputacion\.com/
  ]

  def perform(category_id)
    category = Category.find_by(id: category_id)

    unless category
      Rails.logger.warn("Categoría con id #{category_id} no encontrada.")
      return
    end

    category.links.each do |link|
      if valid_url?(link.url)
        case link.url
        when /venex\.com\.ar/
          ScrapingVenexJob.perform_later(category.id) # Llama al scraping de Venex
        when /hardcorecomputacion\.com/
          ScrapingHardcoreComputacionJob.perform_later(category.id) # Llama al scraping de Hardcore Computación
        end
      else
        Rails.logger.warn("URL no válida: #{link.url}. No se realizará scraping.")
      end
    end
  end

  private

  def valid_url?(url)
    VALID_URLS.any? { |pattern| url =~ pattern }
  end
end
