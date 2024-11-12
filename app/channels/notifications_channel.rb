class NotificationsChannel < ApplicationCable::Channel
  def subscribed
   
    stream_from "category_#{connection.category_id}"
  
  end

  def unsubscribed
   
  end
end
