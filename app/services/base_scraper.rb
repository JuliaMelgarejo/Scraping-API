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
    product_link = product_data[:link]  # Ahora capturamos el link

    existing_product = Product.find_by(name: product_name, category: @category)
    if existing_product
      previous_price = existing_product.price
      if current_price != previous_price
        # Guardar el historial de precios
        PriceHistory.create!(product: existing_product, price: previous_price, date: Date.today)
        existing_product.update!(price: current_price, link: product_link)
        puts "Producto actualizado: #{existing_product.name}, precio anterior guardado en el histórico."
        
        # Calcular el descuento
        discount_percentage = calculate_discount(previous_price, current_price)

        # Enviar notificación solo si el descuento es mayor o igual a 10%
        notify_discount(existing_product, discount_percentage) if discount_percentage >= 10
      else
        puts "El precio no ha cambiado para el producto: #{existing_product.name}"
      end
    else
      product_record = Product.create!(name: product_name, price: current_price, category: @category, link: product_link)
      puts "Producto guardado: #{product_record.name} con ID #{product_record.id}"
    end
  end

  def calculate_discount(previous_price, current_price)
    # Calcula el porcentaje de descuento
    ((previous_price - current_price).to_f / previous_price) * 100
  end

  def notify_discount(product, discount_percentage)
    # Enviar la notificación por WebSocket a todos los suscritos a la categoría
    ActionCable.server.broadcast(
      "category_#{@category.id}",  # Canal de WebSocket de la categoría
      {
        message: "¡Descuento en #{product.name}! El precio ha bajado #{discount_percentage.round(2)}%",
        discount_percentage: discount_percentage.round(2),
        new_price: product.price,
        product_id: product.id,
        link: product.link  # Incluimos el link en la notificación
      }
    )

    # Enviar notificación por correo electrónico a los usuarios suscritos
    @category.subscriptions.each do |subscription|
      begin
        if subscription.user.present?
          # Crear una notificación para guardar en la base de datos
          notification = Notification.create!(
            user: subscription.user,
            product: product,
            message: "¡Descuento en #{product.name} - #{discount_percentage.round(2)}% de descuento! Precio actualizado: #{product.price}",
            status: 'no_enviado' # Inicialmente lo dejamos como pendiente
          )
          puts "Notificación pendiente para #{subscription.user.email} para el producto #{product.name}"

          # Enviar correo de notificación
          NotificationMailer.with(user: subscription.user, product: product, discount_percentage: discount_percentage).discount_email.deliver_later
          
          # Después de intentar enviar el correo, actualizamos el estado
          notification.update!(status: 'enviado')
          puts "Notificación enviada a #{subscription.user.email} para el producto #{product.name}"
        else
          puts "No se encontró usuario para la suscripción"
        end
      rescue => e
        # Si ocurre un error al enviar el correo, actualizamos el estado a 'error'
        puts "Error al enviar la notificación: #{e.message}"
        notification.update!(status: 'error') if notification
      end
    end
  end
end
