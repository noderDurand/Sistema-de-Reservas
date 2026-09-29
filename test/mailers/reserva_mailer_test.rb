require "test_helper"

class ReservaMailerTest < ActionMailer::TestCase
  test "confirmation" do
    reserva = reservas(:one)
    mail = ReservaMailer.confirmation(reserva)

    assert_equal "Reserva Futbol5 Confirmada", mail.subject
    assert_equal [ reserva.user.email ], mail.to
    assert_equal [ "reservas@futbol5.com" ], mail.from
    assert_match reserva.cancha.nombre, mail.body.encoded
  end
end
