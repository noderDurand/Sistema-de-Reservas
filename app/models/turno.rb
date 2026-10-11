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

  # En la API las horas salen como "HH:MM". Por default saldrían como
  # "2000-01-01T18:00:00.000Z": la Z (UTC) hace que el front, al parsearlo
  # con new Date(), lo muestre corrido 3 horas.
  def as_json(options = {})
    super(options).merge(
      "hora_inicio" => hora_inicio&.strftime("%H:%M"),
      "hora_fin" => hora_fin&.strftime("%H:%M")
    )
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
