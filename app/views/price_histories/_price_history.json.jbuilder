json.extract! price_history, :id, :datte, :price, :product_id, :created_at, :updated_at
json.url price_history_url(price_history, format: :json)
