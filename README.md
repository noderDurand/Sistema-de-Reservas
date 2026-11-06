# Futbol5 Reservas

Sistema de reservas de turnos para un complejo de fútbol 5. TP N°1 de
Programación IV — Ruby on Rails. Incluye back-office administrativo y
API JSON para el front-end público (TP2).

## Requisitos
- Ruby 4.0.6
- Rails 8.1.3.1
- SQLite3

## Instalación y ejecución

- git clone <url-del-repo>
- cd futbol5_reservas
- bundle install

## Base de datos

- rails db:create
- rails db:migrate
- rails db:seed

## Levantar el servidor

- rails server
- La app queda disponible en http://localhost:3000

## Acceso al back-office

- URL: http://localhost:3000/admin/login
- Credenciales: 

## Endpoints principales de la API

Base: `/api/v1`

| Método | Endpoint | Auth | Descripción |

| POST | /login | Público | Login, devuelve token |
| POST | /signup | Público | Registro de cliente |
| GET | /canchas | Público | Listado de canchas |
| GET | /canchas/:id | Público | Detalle de una cancha |
| GET | /canchas/:id/turnos_disponibles?fecha=YYYY-MM-DD | Público | Turnos libres de esa cancha/fecha |
| GET | /reservas | Token | Reservas del usuario logueado |
| GET | /reservas/:id | Token | Detalle de una reserva propia |
| POST | /reservas | Token | Crea una reserva (queda confirmada y con pago pendiente + QR) |
| PATCH | /reservas/:id/cancelar | Token | Cancela una reserva propia |
| GET | /profile | Token | Datos del usuario logueado |


## Modelo de datos

- **User**: name, phone, email, password, role (cliente/admin), api_token.
- **Cancha**: nombre, capacidad, precio.
- **Turno**: hora_inicio, hora_fin.
- **Reserva**: fecha, estado (pendiente/confirmada/cancelada). Pertenece
  a Cancha, Turno y User. No permite dos reservas activas para la misma
  cancha+turno+fecha (validación + índice único parcial en la base). Si el
  horario está libre nace `confirmada`, sin aprobación del admin.
- **Pago**: fecha, precio, modo (efectivo/online), estado (pendiente/aprobado),
  token. Pertenece a Reserva (uno por reserva).

## Pago simulado con QR

1. `POST /api/v1/reservas` crea la reserva (`confirmada`) y su pago `pendiente`.
   La respuesta trae `pago: { estado, pago_url, qr_svg }` (el `qr_svg` es el
   QR listo para mostrar en el front; `GET /reservas/:id` lo devuelve igual
   mientras el pago siga pendiente).
2. Al escanear el QR el celular abre `GET /pagos/:token` (público) y el pago
   pasa a `aprobado` (es una simulación, no hay pasarela real).
3. El front consulta `GET /reservas` / `GET /reservas/:id` y ve `pago.estado`.

Para que el celular alcance el servidor, en desarrollo setear la IP de la PC:
`PUBLIC_BASE_URL=http://192.168.0.10:3000 bin/rails server -b 0.0.0.0`
(sin la variable, el QR usa el host del request, ej. `localhost`).

