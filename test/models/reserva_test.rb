require "test_helper"

class ReservaTest < ActiveSupport::TestCase
  test "es válida con datos correctos" do
    reserva = Reserva.new(fecha: Date.tomorrow, cancha: canchas(:one),
                           turno: turnos(:one), user: users(:one))
    assert reserva.valid?
  end

  test "estado por defecto es pendiente" do
    reserva = Reserva.new(fecha: Date.tomorrow, cancha: canchas(:one),
                           turno: turnos(:one), user: users(:one))
    reserva.valid?
    assert_equal "pendiente", reserva.estado
  end

  test "no permite reservar la misma cancha, turno y fecha dos veces" do
    Reserva.create!(fecha: Date.tomorrow, cancha: canchas(:one),
                     turno: turnos(:one), user: users(:one), estado: "confirmada")

    duplicada = Reserva.new(fecha: Date.tomorrow, cancha: canchas(:one),
                             turno: turnos(:one), user: users(:one))

    assert_not duplicada.valid?
    assert_includes duplicada.errors[:cancha_id], "ya esta reservada en ese horario"
  end

  test "permite reservar el mismo horario si la reserva anterior está cancelada" do
    Reserva.create!(fecha: Date.tomorrow, cancha: canchas(:one),
                     turno: turnos(:one), user: users(:one), estado: "cancelada")

    nueva = Reserva.new(fecha: Date.tomorrow, cancha: canchas(:one),
                         turno: turnos(:one), user: users(:one))

    assert nueva.valid?
  end

  test "permite la misma cancha y turno en otra fecha" do
    Reserva.create!(fecha: Date.tomorrow, cancha: canchas(:one),
                     turno: turnos(:one), user: users(:one), estado: "confirmada")

    otra_fecha = Reserva.new(fecha: Date.tomorrow + 1.day, cancha: canchas(:one),
                              turno: turnos(:one), user: users(:one))

    assert otra_fecha.valid?
  end
end
