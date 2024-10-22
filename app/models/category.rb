class Category < ApplicationRecord
  has_many :products
  has_many :links 
  has_many :subscriptions 
end
