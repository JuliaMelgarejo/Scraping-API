class PriceHistory < ApplicationRecord
  belongs_to :product
  after_update :update_method
  private

  def update_method
    Rails.logger.info "PriceHistory with id #{self.id} was updated. Price: #{self.price}"
  end
end
