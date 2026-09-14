# Requerimientos de Backend (API & Base de Datos)

Este documento detalla todas las necesidades de integraciones (endpoints, servicios, etc.) que requerirá el backend para que la aplicación frontend funcione correctamente una vez terminemos la fase de diseño. Se irá actualizando conforme diseñemos más pantallas.

## 1. Autenticación y Autorización
- **POST /api/auth/login**: Endpoint genérico o específico para iniciar sesión.
  - *Request*: `email` (o usuario), `password`.
  - *Response*: Token de autenticación (JWT) y perfil del usuario (`role`: chofer, turista, admin, negocio), `userId`, `name`.

## 2. Funcionalidades de Chofer (Conductor)

### 2.1. Viajes (Trips)
- **GET /api/chofer/trips/today**: Obtener los viajes asignados al chofer para el día actual.
  - *Response*: Lista de viajes (ID, ruta, hora programada, origen, destino, cantidad de pasajeros totales, imagen referencial o tipo de ruta).
- **GET /api/trips/{tripId}**: Obtener el detalle completo de un viaje específico.
  - *Response*: Información detallada del viaje, incluyendo paradas (stops), estado actual (en espera, en curso, finalizado) y el progreso de abordaje (pasajeros a bordo vs totales).
- **POST /api/trips/{tripId}/start**: Marcar un viaje como iniciado o actual.

### 2.2. Pasajeros y Abordaje
- **GET /api/trips/{tripId}/passengers**: Obtener la lista de pasajeros de un viaje en específico.
  - *Response*: Lista de pasajeros (ID del turista, nombre, número de boleto, asiento, estado de abordaje: `isBoarded`).
- **GET /api/tourists/{touristId}**: Obtener información detallada de un pasajero.
  - *Response*: Perfil del turista, requerimientos médicos o de accesibilidad, información de contacto de emergencia, idiomas que habla, tipo de boleto, historial.
- **POST /api/trips/{tripId}/scan**: Validar el escaneo de un código QR.
  - *Request*: `qr_data` (payload encriptado del código QR).
  - *Response*: Si el QR es válido, retornar la info del pasajero. Si no pertenece al viaje o ya fue escaneado, retornar un mensaje de error claro (e.g. "Boleto ya escaneado" o "Pasajero no pertenece a este viaje").
- **POST /api/trips/{tripId}/passengers/{touristId}/board**: Marcar a un pasajero como abordado manualmente o después de escanear su código.

## 3. Consideraciones Técnicas Generales
- **WebSockets / Notificaciones Push**: El backend deberá estar preparado para emitir notificaciones en tiempo real al chofer (ej. cambios de ruta, alertas del administrador, o turistas cancelando a última hora).
- **Manejo de Roles**: Toda petición deberá validar por middleware que el JWT corresponde a un Chofer cuando acceda a las rutas `/api/chofer/...`.

*(Este documento se continuará expandiendo al desarrollar las vistas de Turista, Admin y Negocios).*
