// app/javascript/packs/application.js

import Rails from "@rails/ujs"
import * as ActiveStorage from "@rails/storage"
import "channels" // Esto debe importar el archivo de canales
import "./channels/notifications_channel" // Importa el canal de notificaciones
import "./notifications"; // Asegúrate de importar tu archivo de notificaciones

Rails.start()
ActiveStorage.start()
