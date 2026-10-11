class Reserva < ApplicationRecord
  belongs_to :cancha
  belongs_to :turno
  belongs_to :user
  has_one :pago, dependent: :destroy

  ESTADOS = %w[pendiente confirmada cancelada].freeze

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

  before_validation { self.estado ||= "pendiente" }

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
  def as_json(options = {})
    super({ only: [ :id, :fecha, :estado, :created_at ] }.merge(options)).merge(
      "cancha" => { "id" => cancha.id, "nombre" => cancha.nombre, "precio" => cancha.precio },
      "turno" => turno.as_json(only: [ :id ])
    )
  end

  private

  def fecha_y_turno_no_pasados
    return if fecha.blank?

    if fecha < Date.current
      errors.add(:fecha, "no puede ser una fecha pasada")
    elsif turno&.hora_inicio.present? && turno.empezado_en?(fecha)
      errors.add(:turno, "ya comenzó, elegí un horario posterior")
    end
  end
end
