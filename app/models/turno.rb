class Turno < ApplicationRecord
  has_many :reservas, dependent: :destroy

  validates :hora_inicio, presence: true
  validates :hora_fin, presence: true
  validate :hora_fin_posterior_inicio
  validate :no_se_superpone_con_otro_turno

  def empezado_en?(fecha)
    fecha == Date.current &&
      hora_inicio.seconds_since_midnight <= Time.current.seconds_since_midnight
  end

  private

  def hora_fin_posterior_inicio
    return if hora_inicio.blank? || hora_fin.blank?
    errors.add(:hora_fin, "Debe ser posterior a la hora de inicio") if hora_fin <= hora_inicio
  end

  def no_se_superpone_con_otro_turno
    return if hora_inicio.blank? || hora_fin.blank?

    t = Turno.arel_table
    superpuesto = Turno.where.not(id: id)
                       .where(t[:hora_inicio].lt(hora_fin))
                       .where(t[:hora_fin].gt(hora_inicio))
                       .order(:hora_inicio)
                       .first
    return unless superpuesto

    errors.add(:base, "Se superpone con el turno #{superpuesto.hora_inicio.strftime('%H:%M')} - " \
                      "#{superpuesto.hora_fin.strftime('%H:%M')}")
  end
end
