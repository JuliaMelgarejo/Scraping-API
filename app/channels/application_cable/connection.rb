module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :category_id

    def connect
      self.category_id = request.params[:category_id]
      Rails.logger.info "Connected with category_id=#{category_id}"
      NotificationsChannel.action_methods
    
    end
  end
end