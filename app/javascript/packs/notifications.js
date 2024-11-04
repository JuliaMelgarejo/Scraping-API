import consumer from "../consumer.js";

document.addEventListener("DOMContentLoaded", () => {
  console.log("JavaScript cargado correctamente");

  const sendNotificationButton = document.getElementById("send-notification");

  if (sendNotificationButton) {
    sendNotificationButton.addEventListener("click", () => {
      console.log("Botón de notificación clicado");
      fetch('/products/1/send_test_notification', {
        method: 'POST',
        headers: {
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
        }
      })
      .then(response => {
        if (response.ok) {
          alert("Notificación enviada exitosamente.");
        } else {
          alert("Error al enviar la notificación.");
        }
      })
      .catch(error => {
        console.error("Error en la solicitud:", error);
      });
    });
  }
});

  