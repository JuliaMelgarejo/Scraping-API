class NotificationsChannel < ApplicationCable::Channel
  def subscribed
    # Se suscribe al canal de notificaciones basado en la categoría
    stream_from "notifications_#{params[:category_id]}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
