# app/workers/mercado_libre_scraping_worker.rb
# app/jobs/mercado_libre_scraping_job.rb
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
        price_text = item.css('.poly-price__current .andes-money-amount__fraction').text.strip
        price = price_text.gsub('.', '').to_f

        if title.present? && price > 0
          # Si quieres almacenar la marca también, agrega un campo en la base de datos para ello.
          Product.create!(name: " #{title}".strip, price: price)
          Rails.logger.info "Producto guardado:#{title}, Precio: #{price}"
        else
          Rails.logger.warn "Datos incompletos: Título: #{title.inspect}, Precio: #{price.inspect}"
        end
      end

    rescue HTTParty::Error => e
      Rails.logger.error "Error al hacer la solicitud HTTP: #{e.message}"
    rescue StandardError => e
      Rails.logger.error "Error en el scraping: #{e.message}"
    end
  end
end







# class MercadoLibreScrapingWorker
#   include Sidekiq::Worker

#   def perform(url)
#     # 1. Realizar la petición HTTP a la URL de MercadoLibre
#     response = HTTParty.get(url)

#     # 2. Parsear el HTML usando Nokogiri
#     parsed_page = Nokogiri::HTML(response.body)

#     # 3. Extraer la información de cada notebook (título, precio, etc.)
#     parsed_page.css('.ui-search-result__wrapper').each do |item|
#       title = item.css('.ui-search-item__title').text.strip
#       price = item.css('.price-tag-fraction').text.strip

#       # Almacenar o mostrar los datos (en este caso los imprime en consola)
#       puts "Notebook: #{title}, Precio: $#{price}"

#       # Aquí podrías guardar los datos en la base de datos si lo deseas
#       # Product.create!(name: title, price: price)
#     end
#   end
# end
