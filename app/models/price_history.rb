class PriceHistory < ApplicationRecord
  belongs_to :product

  # Definir un callback después de actualizar
  after_update :update_method

  private

  def update_method
    # Lógica que deseas ejecutar después de una actualización de PriceHistory
    # Por ejemplo, puedes guardar un nuevo precio, realizar una validación o cualquier otra acción
    Rails.logger.info "PriceHistory with id #{self.id} was updated. Price: #{self.price}"
  end
end
