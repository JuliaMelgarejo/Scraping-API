# app/controllers/scraping_controller.rb

class ScrapingController < ApplicationController
  def start_scraping
    url = 'https://listado.mercadolibre.com.ar/notebook'

    # Enviar el trabajo al worker de Sidekiq
    MercadoLibreScrapingJob.perform_now(url)

    render json: { message: "Scraping iniciado" }, status: :ok
  end
end
