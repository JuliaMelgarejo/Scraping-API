class Product < ApplicationRecord
  belongs_to :category
  has_many :notifications
  has_many :price_histories
end


#validates :name, presence: true
#validates :price, presence: true