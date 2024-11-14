class ScrapingHardcoreComputacion < BaseScraper
  private
  def extract_products(document)
    document.css('.product-small.box').map do |product|
      name_element = product.at_css('.woocommerce-loop-product__title a')
      price_element = product.at_css('.woocommerce-Price-amount bdi')
      next unless name_element && price_element

      # Obtener el enlace correctamente desde el atributo 'href' de 'a'
      link = name_element['href'] if name_element

      {
        name: name_element.text.strip,
        price: price_element.text.strip.gsub(/\D/, '').to_i,
        link: link
      }
    end.compact
  end
end
