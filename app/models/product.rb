class Product < ApplicationRecord
  belongs_to :category
  has_many :notifications
  has_many :price_histories

  # Método para manejar la notificación
  def notify_price_change
    # Emisión de la notificación a los usuarios suscritos a la categoría
    ActionCable.server.broadcast(
      "notifications_#{self.category_id}",
      message: "El precio del producto '#{self.name}' ha cambiado a #{self.price}.",
      product_id: self.id
    )
  end
end

#validates :name, presence: true
#validates :price, presence: true