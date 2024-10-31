
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

  # Código para el scraper con manejo de duplicación y actualización de precio

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

      puts "Extrayendo producto: #{product_name}, precio actual: #{current_price}"

      # Buscar si el producto ya existe en la base de datos
      existing_product = Product.find_by(name: product_name, category: @category)

      if existing_product
        # Si el precio ha cambiado, guarda el precio anterior en el histórico y actualiza el producto
        if existing_product.price != current_price
          PriceHistory.create!(
            product: existing_product,
            price: existing_product.price,
            date: Date.today # Guarda la fecha del cambio de precio
          )
          existing_product.update!(price: current_price)
          puts "Producto actualizado: #{existing_product.name}, precio anterior guardado en el histórico."
        else
          puts "El precio no ha cambiado para el producto: #{existing_product.name}"
        end
      else
        # Crear un nuevo producto si no existe
        product_record = Product.create!(
          name: product_name,
          price: current_price,
          category: @category
        )
        puts "Producto guardado: #{product_record.name} con ID #{product_record.id}"
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