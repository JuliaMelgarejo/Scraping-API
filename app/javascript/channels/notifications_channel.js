import consumer from "./consumer";

const channel = consumer.subscriptions.create("NotificationsChannel", {
  connected() {
    console.log("Conectado al canal de notificaciones");
  },

  disconnected() {
    console.log("Desconectado del canal de notificaciones");
  },

  received(data) {
    console.log("Recibido por WebSocket:", data);
    // Puedes mostrar el mensaje en la interfaz de usuario
    document.getElementById("messages").innerHTML += `<p>${data.message}</p>`;
  }
});

// Enviar un mensaje cada 5 segundos al servidor
setInterval(() => {
  channel.send({ message: "Mensaje enviado cada 5 segundos" });
}, 5000);
