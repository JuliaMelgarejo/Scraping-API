# app/services/scraping_venex.rb
require 'nokogiri'
require 'open-uri'

class ScrapingVenex
  def initialize(category)
    @category = category
  end

  def scrape_links
    @category.links.each do |link|
      scrape(link.url)
    end
  end

  private

  def scrape(url)
    begin
      document = Nokogiri::HTML(URI.open(url))
  
      products = document.css('.item')
      
      puts "Encontrados #{products.size} productos en #{url}"
  
      products.each do |product|
        product_name_element = product.at_css('.product-box-title a')
        if product_name_element
          product_name = product_name_element.text.strip
        else
          puts "No se encontró el nombre del producto en el contenedor."
          next
        end
  
        current_price = product.at_css('.current-price').text.strip.gsub(/\D/, '').to_i
  
        puts "Extrayendo producto: #{product_name}, price Actual: #{current_price}"
  
        begin
          product_record = Product.create!(
            name: product_name,
            price: current_price,
            category: @category
          )
          puts "Producto guardado: #{product_record.name} con ID #{product_record.id}"
        rescue ActiveRecord::RecordInvalid => e
          puts "Error al guardar el producto: #{e.record.errors.full_messages.join(', ')}"
        end
      end
  
      puts "Scraping completado para #{url}"
    rescue OpenURI::HTTPError => e
      puts "Error al acceder a #{url}: #{e.message}"
    rescue StandardError => e
      puts "Error inesperado: #{e.message}"
    end
  end
  
end
