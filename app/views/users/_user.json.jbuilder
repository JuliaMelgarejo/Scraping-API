json.extract! user, :id, :userName, :mail, :password, :created_at, :updated_at
json.url user_url(user, format: :json)
