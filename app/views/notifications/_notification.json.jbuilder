json.extract! notification, :id, :staus, :message, :user_id, :product_id, :created_at, :updated_at
json.url notification_url(notification, format: :json)
