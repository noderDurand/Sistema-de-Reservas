class Pago < ApplicationRecord
  belongs_to :reserva

  MODOS = %w[efectivo online].freeze

  validates :fecha, presence: true
  validates :monto, numericality: { greater_than: 0 }
  validates :modo, inclusion: { in: MODOS }
end
