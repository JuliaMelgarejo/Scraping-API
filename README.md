# README

## Descripción del Proyecto

Este proyecto es el resultado final del Bootcamp de Backend 2024, donde hemos desarrollado una aplicación web y una API RESTful. La aplicación permite a los usuarios suscribirse a notificaciones de oportunidades de compra a través de WebSockets, proporcionando alertas en tiempo real sobre descuentos y rebajas en productos de diversas categorías.

## Tecnologías Utilizadas

- **Ruby on Rails 7**: Framework principal para el desarrollo de la aplicación y la API.
- **Sidekiq**: Gestión de trabajos en segundo plano (jobs) para el scraping de datos y notificaciones.
- **Redis**: Almacenamiento en memoria utilizado por Sidekiq para la gestión de trabajos.
- **WebSockets**: Protocolo para la comunicación en tiempo real, permitiendo que los usuarios reciban notificaciones instantáneamente.
- **Docker**: Contenerización de la aplicación para facilitar su despliegue y gestión de entornos.
- **JWT (JSON Web Tokens)**: Método de autenticación para la API, asegurando que solo los usuarios autorizados puedan acceder a ciertos recursos.

## Funcionalidades Principales

1. **Panel de Administración**:
   - Gestión de categorías de productos y URLs para scraping.
   - Administración de usuarios con autenticación mediante correo electrónico y contraseña.
   - Envío de invitaciones a nuevos usuarios.

2. **Motor de Scraping**:
   - Scraping de productos de diversas URLs configuradas en el panel de administración.
   - Almacenamiento en base de datos, manteniendo un histórico de precios.
   - Detección de oportunidades de rebajas y notificación a los usuarios suscritos.

3. **API RESTful**:
   - Autenticación de usuarios mediante JWT.
   - Endpoints para listar categorías, y suscribirse/desuscribirse a ellas.
   - Notificaciones en tiempo real a través de WebSockets cuando se detectan oportunidades de compra.
