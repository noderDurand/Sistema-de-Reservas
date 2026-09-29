class ReservaMailer < ApplicationMailer
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.reserva_mailer.confirmation.subject
  #
  def confirmation(reserva)
    @reserva = reserva
    @user = reserva.user
    @cancha = reserva.cancha
    @turno = reserva.turno

    mail(to: @user.email, subject: "Reserva Futbol5 Confirmada")
  end
end
