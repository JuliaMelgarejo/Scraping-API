class ApplicationController < ActionController::Base
  # def after_sign_in_path_for(resource)
  #   categories_path # O la ruta que apunta a la vista de categorías
  # end
  include JsonWebToken

  before_action :authentication_request

  private

   def authentication_request
      header = request.headers['Authorization']
      header = header.split(' ').last if header
      decoded = jwt_decode(header)
      @current_user_id = User.find(decoded[:user_id])
   end
   
end
