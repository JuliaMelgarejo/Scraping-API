# app/services/base_scraper.rb
require 'nokogiri'
require 'open-uri'

class BaseScraper
  def initialize(category)
    @category = category
  end

  def scrape_links
    @category.links.each do |link|
      scrape(link.url)
    end
  end

  private

  # Este método debe ser implementado en las subclases para cada sitio
  def extract_products(document)
    raise NotImplementedError, "Debes implementar el método extract_products en una subclase"
  end

  # Método base para scraping
  def scrape(url)
    begin
      document = Nokogiri::HTML(URI.open(url))
      products = extract_products(document)

      products.each do |product|
        process_product(product)
      end

      puts "Scraping completado para #{url}"
    rescue OpenURI::HTTPError => e
      puts "Error al acceder a #{url}: #{e.message}"
    rescue StandardError => e
      puts "Error inesperado: #{e.message}"
    end
  end

  # Procesar y actualizar o crear productos en la base de datos
  def process_product(product_data)
    product_name = product_data[:name]
    current_price = product_data[:price]

    existing_product = Product.find_by(name: product_name, category: @category)

    if existing_product
      previous_price = existing_product.price
      if current_price != previous_price
        PriceHistory.create!(product: existing_product, price: previous_price, date: Date.today)
        existing_product.update!(price: current_price)
        puts "Producto actualizado: #{existing_product.name}, precio anterior guardado en el histórico."

        # Calcula el descuento y notifica si es mayor o igual al 10%
        discount_percentage = calculate_discount(previous_price, current_price)
        notify_discount(existing_product, discount_percentage) if discount_percentage >= 10
      else
        puts "El precio no ha cambiado para el producto: #{existing_product.name}"
      end
    else
      product_record = Product.create!(name: product_name, price: current_price, category: @category)
      puts "Producto guardado: #{product_record.name} con ID #{product_record.id}"
    end
  end

  # Método para calcular el porcentaje de descuento
  def calculate_discount(previous_price, current_price)
    ((previous_price - current_price).to_f / previous_price) * 100
  end

  # Método para notificar por WebSocket si hay un descuento
  def notify_discount(product, discount_percentage)
    # Aquí se transmite la notificación de WebSocket a todos los usuarios suscritos a la categoría del producto.
    ActionCable.server.broadcast(
      "notifications_#{@category.id}",  # El canal de WebSocket es dinámico según la categoría.
      {
        message: "Descuento en #{product.name}!",   # Mensaje que recibirá el cliente.
        discount_percentage: discount_percentage.round(2),  # Porcentaje de descuento.
        new_price: product.price,  # Nuevo precio del producto.
        product_id: product.id  # ID del producto
      }
    )
  
   
    @category.subscriptions.each do |subscription|
      NotificationMailer.with(user: subscription.user, product: product, discount_percentage: discount_percentage).discount_email.deliver_later
    end
  end
end
