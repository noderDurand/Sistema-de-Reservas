# Cancela las reservas pendientes que no se pagaron dentro del plazo
# (Reserva::MINUTOS_PARA_PAGAR) y libera su horario. Corre cada minuto en
# producción (config/recurring.yml).
class ExpirarReservasJob < ApplicationJob
  queue_as :default

  def perform
    Reserva.expirar_vencidas
  end
end
