# app/jobs/generic_scraping_job.rb
class GenericScrapingJob < ApplicationJob
  queue_as :default

  VALID_URLS = [
    /venex\.com\.ar/,
    /hardcorecomputacion\.com/
  ]

  def perform
    Category.find_each do |category|
      category.links.each do |link|
        if valid_url?(link.url)
          case link.url
          when /venex\.com\.ar/
            ScrapingVenexJob.perform_later(category.id)
          when /hardcorecomputacion\.com/
            ScrapingHardcoreComputacionJob.perform_later(category.id)
          end
        else
          Rails.logger.warn("URL no válida: #{link.url}. No se realizará scraping.")
        end
      end
    end
  end

  private

  def valid_url?(url)
    VALID_URLS.any? { |pattern| url =~ pattern }
  end
end
