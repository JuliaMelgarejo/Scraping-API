class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  enum role: { standard: 0, admin: 1 }
  has_many :subscriptions
  has_many :notifications

  require "securerandom"
  has_secure_password

  validates :mail, presence: true, uniqueness: true
  validates :userName, presence: true, uniqueness: true
  validates :password, presence: true, length: { minimum: 6 }, on: :create 

end

