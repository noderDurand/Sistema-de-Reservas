class Reserva < ApplicationRecord
  belongs_to :cancha
  belongs_to :turno
  belongs_to :user
  has_one :pago, dependent: :destroy

  ESTADOS = %w[pendiente confirmada cancelada].freeze
  # Tiempo para pagar una reserva pendiente; pasado esto se cancela sola.
  MINUTOS_PARA_PAGAR = 15

  validates :fecha, presence: true
  validates :estado, inclusion: { in: ESTADOS }
  validates :cancha_id, uniqueness: {
    scope: [ :turno_id, :fecha ],
    conditions: -> { where.not(estado: "cancelada") },
    message: "ya esta reservada en ese horario"
  }
  # Solo al crear: el admin tiene que poder cambiar el estado de reservas
  # viejas (ej. cancelar o confirmar una de ayer) sin que esto lo bloquee.
  validate :fecha_y_turno_no_pasados, on: :create

  # Sin revisión del admin: la reserva nace pendiente (ya ocupa el horario,
  # por la validación de unicidad) y pasa a confirmada sola cuando se aprueba
  # su pago (Pago#aprobar, al escanear el QR).
  before_validation { self.estado ||= "pendiente" }

  # Toda reserva nueva genera su pago pendiente (el que se paga con el QR).
  # Va en after_create: corre en la misma transacción que el save, o se
  # guardan las dos cosas o ninguna.
  after_create :generar_pago_pendiente

  # Cancela todas las reservas pendientes que pasaron el plazo de pago y así
  # libera el horario. La llama el job recurrente (producción) y también la
  # API justo antes de mirar disponibilidad o reservar, para que el resultado
  # sea exacto aunque el job no haya corrido todavía (en desarrollo no corre).
  def self.expirar_vencidas
    vencidas.update_all(estado: "cancelada", updated_at: Time.current)
  end

  scope :vencidas, -> { where(estado: "pendiente").where(created_at: ...MINUTOS_PARA_PAGAR.minutes.ago) }

  # Momento en que se cancela por falta de pago (solo mientras está pendiente).
  def vence_en
    created_at + MINUTOS_PARA_PAGAR.minutes if estado == "pendiente"
  end

  def vencida?
    vence_en.present? && vence_en <= Time.current
  end

  # true si la reserva es de un día anterior o de un turno de hoy que ya empezó
  def pasada?
    fecha < Date.current || turno.empezado_en?(fecha)
  end

  # Cancela la reserva (la usa el cliente desde la API). Devuelve false y
  # deja el motivo en errors si ya estaba cancelada o si ya pasó.
  def cancelar
    if estado == "cancelada"
      errors.add(:base, "La reserva ya está cancelada")
      return false
    end

    if pasada?
      errors.add(:base, "No se puede cancelar una reserva que ya pasó o ya empezó")
      return false
    end

    update(estado: "cancelada")
  end

  # JSON para la API: en vez de cancha_id/turno_id manda los datos que el
  # front necesita mostrar ("Cancha 1, 18:00 - 19:00"). Se arma a mano para
  # no incluir la foto de la cancha (otra query por reserva).
  # Incluye el pago (estado, y el QR si se pasa con_qr: true + base_url).
  def as_json(options = {})
    super({ only: [ :id, :fecha, :estado, :created_at ] }.merge(options)).merge(
      "cancha" => { "id" => cancha.id, "nombre" => cancha.nombre, "precio" => cancha.precio },
      "turno" => turno.as_json(only: [ :id ]),
      "vence_en" => vence_en,
      "pago" => pago&.as_json(options.slice(:con_qr, :base_url))
    )
  end

  private

  def generar_pago_pendiente
    create_pago!(precio: cancha.precio, modo: "online", estado: "pendiente")
  end

  def fecha_y_turno_no_pasados
    return if fecha.blank?

    if fecha < Date.current
      errors.add(:fecha, "no puede ser una fecha pasada")
    elsif turno&.hora_inicio.present? && turno.empezado_en?(fecha)
      errors.add(:turno, "ya comenzó, elegí un horario posterior")
    end
  end
end
