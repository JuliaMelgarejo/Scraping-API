class NotificationsChannel < ApplicationCable::Channel
  def subscribed
    stream_for "notifications_1"
  end

  def unsubscribed
  end

  def receive(data)
    ActionCable.server.broadcast("notifications_1", message: data['message'])
  end
end
