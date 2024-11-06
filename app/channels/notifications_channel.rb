class NotificationsChannel < ApplicationCable::Channel
  def subscribed
    stream_for "notifications_1"  # Canal al que están suscritos los usuarios
  end

  def unsubscribed
    # Código para manejar cuando el usuario se desuscribe (si es necesario)
  end

  def receive(data)
    # Aquí recibimos el mensaje del cliente y lo enviamos a todos los suscriptores
    ActionCable.server.broadcast("notifications_1", message: data['message'])
  end
end
