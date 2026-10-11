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

  # --- fechas y turnos pasados (turno one = 18:00-19:00, two = 19:00-20:00) ---

  test "no permite reservar una fecha pasada" do
    reserva = Reserva.new(fecha: Date.yesterday, cancha: canchas(:one),
                          turno: turnos(:one), user: users(:one))

    assert_not reserva.valid?
    assert_includes reserva.errors[:fecha], "no puede ser una fecha pasada"
  end

  test "no permite reservar hoy un turno que ya empezó" do
    travel_to Time.zone.local(2026, 10, 11, 18, 30) do
      reserva = Reserva.new(fecha: Date.current, cancha: canchas(:one),
                            turno: turnos(:one), user: users(:one))

      assert_not reserva.valid?
      assert_includes reserva.errors[:turno], "ya comenzó, elegí un horario posterior"
    end
  end

  test "permite reservar hoy un turno que todavía no empezó" do
    travel_to Time.zone.local(2026, 10, 11, 18, 30) do
      reserva = Reserva.new(fecha: Date.current, cancha: canchas(:one),
                            turno: turnos(:two), user: users(:one))

      assert reserva.valid?
    end
  end

  test "usa la hora de Argentina: a las 22hs todavía es el mismo día" do
    # 22:00 en Buenos Aires = 01:00 UTC del día siguiente
    travel_to Time.zone.local(2026, 10, 11, 22, 0) do
      reserva = Reserva.new(fecha: Date.new(2026, 10, 11), cancha: canchas(:one),
                            turno: turnos(:one), user: users(:one))

      reserva.valid?
      # Si se usara UTC, ya sería 12/10 y daría "fecha pasada" en vez de esto
      assert_empty reserva.errors[:fecha]
      assert_includes reserva.errors[:turno], "ya comenzó, elegí un horario posterior"
    end
  end

  test "el admin puede cambiar el estado de una reserva con fecha pasada" do
    reserva = reservas(:one)
    reserva.update_column(:fecha, Date.yesterday)

    assert reserva.update(estado: "cancelada")
  end

  # --- cancelar ---

  test "cancelar cambia el estado a cancelada" do
    reserva = reservas(:one)

    assert reserva.cancelar
    assert_equal "cancelada", reserva.reload.estado
  end

  test "no se puede cancelar dos veces" do
    reserva = reservas(:one)
    reserva.update!(estado: "cancelada")

    assert_not reserva.cancelar
    assert_includes reserva.errors[:base], "La reserva ya está cancelada"
  end

  test "no se puede cancelar una reserva de hoy cuyo turno ya empezó" do
    travel_to Time.zone.local(2026, 10, 11, 18, 30) do
      reserva = reservas(:one)
      reserva.update_column(:fecha, Date.current)

      assert_not reserva.cancelar
      assert_equal "pendiente", reserva.reload.estado
    end
  end

  test "cancelar libera el horario para otra reserva" do
    reservas(:one).cancelar

    nueva = Reserva.new(fecha: reservas(:one).fecha, cancha: reservas(:one).cancha,
                        turno: reservas(:one).turno, user: users(:two))
    assert nueva.valid?
  end
end
