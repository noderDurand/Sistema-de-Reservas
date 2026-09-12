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

  before_validation { self.estado ||= "pendiente" }
end
