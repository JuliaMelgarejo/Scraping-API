# lib/tasks/test_notification.rb

# Configura estos valores según tu entorno
category_id = 1 # Debe coincidir con el ID al que estás suscrito en wscat
product_name = "Producto de Prueba"
new_price = 100.0 # Nuevo precio simulado
old_price = 150.0 # Precio anterior simulado

# Calcula el porcentaje de descuento
discount_percentage = ((old_price - new_price) / old_price) * 100

# Enviar la notificación por WebSocket usando Action Cable
ActionCable.server.broadcast(
  "notifications_#{category_id}",
  {
    message: "Descuento en #{product_name}!",
    discount_percentage: discount_percentage.round(2),
    new_price: new_price,
    old_price: old_price
  }
)

puts "Notificación de descuento enviada al canal notifications_#{category_id} con un descuento del #{discount_percentage.round(2)}%"
