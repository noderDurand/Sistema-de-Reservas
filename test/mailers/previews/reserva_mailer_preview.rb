# Preview all emails at http://localhost:3000/rails/mailers/reserva_mailer
class ReservaMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/reserva_mailer/confirmation
  def confirmation
    ReservaMailer.confirmation
  end
end
