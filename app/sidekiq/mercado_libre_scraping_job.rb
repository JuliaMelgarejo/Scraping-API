# app/workers/mercado_libre_scraping_worker.rb
# app/jobs/mercado_libre_scraping_job.rb
require 'bigdecimal'
require 'bigdecimal/util'

class MercadoLibreScrapingJob < ApplicationJob
  queue_as :default

  def perform(url)
    begin
      # Lógica de scraping
      response = HTTParty.get(url)
      parsed_page = Nokogiri::HTML(response.body)

      # Guardar el HTML recibido para revisión
      File.open("scraping_output.html", "w") { |f| f.write(parsed_page.to_html) }

      parsed_page.css('.ui-search-result__wrapper').each do |item|
        # Obtener el título del producto (nombre)
        title = item.css('.poly-component__title a').text.strip

        # Obtener el precio actual
        price_text = item.css('.andes-money-amount--current .andes-money-amount__fraction').text.strip
        if price_text.blank?
          # Si el precio actual no está disponible, intenta obtener el precio anterior
          price_text = item.css('.andes-money-amount--previous .andes-money-amount__fraction').text.strip
        end

        # Verificar que price_text no esté vacío antes de procesarlo
        next if price_text.blank?

        # Eliminar puntos y convertir a BigDecimal
        price = price_text.gsub('.', '').to_d # Convertir a BigDecimal

        if title.present? && price > 0
          # Almacenar el producto con su nombre y precio
          Product.create!(name: title.strip, price: price)
          Rails.logger.info "Producto guardado: #{title}, Precio: #{price}"
        else
          Rails.logger.warn "Datos incompletos: Título: #{title.inspect}, Precio: #{price.inspect}"
        end
        #Rails.logger.info "Precio procesado: #{price}"
      end
    rescue HTTParty::Error => e
      Rails.logger.error "Error al hacer la solicitud HTTP: #{e.message}"
    rescue StandardError => e
      Rails.logger.error "Error en el scraping: #{e.message}"
    end
  end
end
