# app/jobs/generic_scraping_job.rb
class GenericScrapingJob < ApplicationJob
  queue_as :default

  VALID_URLS = [
    /venex\.com\.ar/,
    /hardcorecomputacion\.com/
  ]

  def perform(category_id)
    category = Category.find(category_id)

    category.links.each do |link|
      if valid_url?(link.url)
        case link.url
        when /venex\.com\.ar/
          ScrapingVenex.perform_later(category_id) # Llama al scraping de Venex
        when /hardcorecomputacion\.com/
          ScrapingHardcoreComputacion.perform_later(category_id) # Llama al scraping de otra página
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
