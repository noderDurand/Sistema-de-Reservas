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
