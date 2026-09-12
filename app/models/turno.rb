class Turno < ApplicationRecord
  has_many :reservas, dependent: :destroy

  validates :hora_inicio, presence: true
  validates :hora_fin, presence: true
  validate :hora_fin_posterior_inicio

  private

  def hora_fin_posterior_inicio
    return if hora_inicio.blank? || hora_fin.blank?
    errors.add(:hora_fin, "Debe ser posterior a la hora de inicio") if hora_fin <= hora_inicio
  end
end
