class Subscription < ApplicationRecord
  belongs_to :user
  belongs_to :category

  validates :user, presence: true
  validates :category, presence: true
end
