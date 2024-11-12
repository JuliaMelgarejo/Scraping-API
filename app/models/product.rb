class Product < ApplicationRecord
  belongs_to :category
  has_many :notifications
  has_many :price_histories

  def notify_price_change
    ActionCable.server.broadcast(
      "notifications_#{self.category_id}",
      message: "El precio del producto '#{self.name}' ha cambiado a #{self.price}.",
      product_id: self.id
    )
  end
end