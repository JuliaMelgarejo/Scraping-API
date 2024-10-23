# app/models/product.rb

class Product < ApplicationRecord
  validates :name, presence: true
  validates :price, presence: true
end
