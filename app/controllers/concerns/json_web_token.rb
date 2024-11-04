require 'jwt'

module JsonWebToken
  extend ActiveSupport::Concern

  SECRET_KEY = Rails.application.secret_key_base
  
  def self.jwt_encode(payload, exp = 24.hours.from_now)
    payload[:exp] = exp.to_i
    JWT.encode(payload, SECRET_KEY, 'HS256')
  end

  def self.jwt_decode(token)
    decoded = JWT.decode(token, SECRET_KEY, true, algorithm: 'HS256')[0]
    HashWithIndifferentAccess.new(decoded)
  end


end
