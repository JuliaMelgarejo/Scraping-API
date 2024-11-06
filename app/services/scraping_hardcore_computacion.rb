# app/services/scraping_hardcore_computacion.rb
class ScrapingHardcoreComputacion < BaseScraper
  private

  def extract_products(document)
    document.css('.product-small.box').map do |product|
      name_element = product.at_css('.woocommerce-loop-product__title a')
      price_element = product.at_css('.woocommerce-Price-amount bdi')

      next unless name_element && price_element

      {
        name: name_element.text.strip,
        price: price_element.text.strip.gsub(/\D/, '').to_i
      }
    end.compact
  end
end
