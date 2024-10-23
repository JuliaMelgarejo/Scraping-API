Rails.application.routes.draw do
  # Ruta para iniciar el scraping
  get 'start_scraping', to: 'scraping#start_scraping'
end
