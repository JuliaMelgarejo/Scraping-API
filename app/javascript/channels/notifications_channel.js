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
    document.getElementById("messages").innerHTML += `<p>${data.message}</p>`;
  }
});

setInterval(() => {
  channel.send({ message: "Mensaje enviado cada 5 segundos" });
}, 5000);
