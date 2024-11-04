require 'nokogiri'
require 'open-uri'

class ScrapingHardcoreComputacion
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
      puts "Accediendo a: #{url}"
      document = Nokogiri::HTML(URI.open(url))
      puts "Documentación obtenida con éxito."

      products = document.css('.product-small.box')
      puts "Encontrados #{products.size} productos en #{url}"

      products.each do |product|
        product_name_element = product.at_css('.woocommerce-loop-product__title a')
        if product_name_element
          product_name = product_name_element.text.strip
          puts "Nombre del producto encontrado: #{product_name}"
        else
          puts "No se encontró el nombre del producto en el contenedor."
          next
        end

        current_price_element = product.at_css('.woocommerce-Price-amount bdi')
        if current_price_element
          current_price = current_price_element.text.strip.gsub(/\D/, '').to_i
          puts "Precio actual del producto: #{current_price}"
        else
          puts "No se encontró el precio del producto en el contenedor."
          next
        end

        puts "Extrayendo producto: #{product_name}, precio actual: #{current_price}"

        existing_product = Product.find_by(name: product_name, category: @category)

        if existing_product
          
          previous_price = existing_product.price
          price_difference = previous_price - current_price
          discount_percentage = (price_difference.to_f / previous_price) * 100

          if current_price != previous_price
            
            PriceHistory.create!(
              product: existing_product,
              price: previous_price,
              date: Date.today 
            )

            existing_product.update!(price: current_price)
            puts "Producto actualizado: #{existing_product.name}, precio anterior guardado en el histórico."

           
            if discount_percentage >= 10
              puts "¡Oferta! El precio actual es un #{discount_percentage.round(2)}% menor que el precio anterior."
              #
              #Logica para notificar
              #
              #
            end
          else
            puts "El precio no ha cambiado para el producto: #{existing_product.name}"
          end
        else
          
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
