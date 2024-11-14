class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :product

  enum status: { no_enviado: 0, enviado: 1, error: 2, pendiente: 3 }  # Define los posibles estados

  validates :user, presence: true
  validates :product, presence: true
  validates :status, presence: true

end
