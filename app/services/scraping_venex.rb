class ScrapingVenex < BaseScraper
  private
  def extract_products(document)
    document.css('.item').map do |product|
      name_element = product.at_css('.product-box-title a')
      price_element = product.at_css('.current-price')
      next unless name_element && price_element

      # Obtener el enlace del producto
      link = name_element['href']

      {
        name: name_element.text.strip,
        price: price_element.text.strip.gsub(/\D/, '').to_i,
        link: link
      }
    end.compact
  end
end
