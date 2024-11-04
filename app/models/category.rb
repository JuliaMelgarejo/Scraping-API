class Category < ApplicationRecord
  has_many :products, dependent: :destroy
  has_many :links, dependent: :destroy
  has_many :subscriptions
  accepts_nested_attributes_for :links 
end
