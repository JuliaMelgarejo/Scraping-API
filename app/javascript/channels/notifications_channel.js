import consumer from "./consumer"

const categoryId = document.getElementById('category-id')?.value; // Asegúrate de tener un elemento con ese ID

if (categoryId) {
  consumer.subscriptions.create({ channel: "NotificationsChannel", category_id: categoryId }, {
    connected() {
      console.log("Conectado al canal de notificaciones");
    },

    disconnected() {
      console.log("Desconectado del canal de notificaciones");
    },

    received(data) {
      alert(data.message); // Maneja la notificación aquí
    }
  });
}
