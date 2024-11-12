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

  def extract_products(document)
    raise NotImplementedError, "Debes implementar el método extract_products en una subclase"
  end

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

  def process_product(product_data)
    product_name = product_data[:name]
    current_price = product_data[:price]

    existing_product = Product.find_by(name: product_name, category: @category)
    if existing_product
      previous_price = existing_product.price
      if current_price != previous_price
        # Guardar el historial de precios
        PriceHistory.create!(product: existing_product, price: previous_price, date: Date.today)
        existing_product.update!(price: current_price)
        puts "Producto actualizado: #{existing_product.name}, precio anterior guardado en el histórico."
        
        # Calcular el descuento
        discount_percentage = calculate_discount(previous_price, current_price)

        # Enviar notificación solo si el descuento es mayor o igual a 10%
        notify_discount(existing_product, discount_percentage) if discount_percentage >= 10
      else
        puts "El precio no ha cambiado para el producto: #{existing_product.name}"
      end
    else
      product_record = Product.create!(name: product_name, price: current_price, category: @category)
      puts "Producto guardado: #{product_record.name} con ID #{product_record.id}"
    end
  end

  def calculate_discount(previous_price, current_price)
    ((previous_price - current_price).to_f / previous_price) * 100
  end

  def notify_discount(product, discount_percentage)
    # Enviar la notificación por WebSocket a todos los suscritos a la categoría
    ActionCable.server.broadcast(
      "category_#{@category.id}",  # Canal de WebSocket de la categoría
      {
        message: "Descuento en #{product.name}!",
        discount_percentage: discount_percentage.round(2),
        new_price: product.price,
        product_id: product.id
      }
    )

    # Enviar notificación por correo electrónico a los usuarios suscritos
    @category.subscriptions.each do |subscription|
      NotificationMailer.with(user: subscription.user, product: product, discount_percentage: discount_percentage).discount_email.deliver_later
    end
  end
end
