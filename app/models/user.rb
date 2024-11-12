class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  enum role: { standard: 0, admin: 1 }
  has_many :subscriptions
  has_many :notifications
  has_many :categories, through: :subscriptions

end
