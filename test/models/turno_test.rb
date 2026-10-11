require "test_helper"

class TurnoTest < ActiveSupport::TestCase
  test "es válido con datos correctos" do
    turno = Turno.new(hora_inicio: "20:00", hora_fin: "21:00")
    assert turno.valid?
  end

  test "hora_fin debe ser posterior a hora_inicio" do
    turno = Turno.new(hora_inicio: "19:00", hora_fin: "18:00")
    assert_not turno.valid?
    assert_includes turno.errors[:hora_fin], "Debe ser posterior a la hora de inicio"
  end

  # Fixtures: one = 18:00-19:00, two = 19:00-20:00

  test "no permite un turno que se pisa parcialmente con otro" do
    turno = Turno.new(hora_inicio: "18:30", hora_fin: "19:30")
    assert_not turno.valid?
    assert_includes turno.errors[:base], "Se superpone con el turno 18:00 - 19:00"
  end

  test "no permite un turno contenido dentro de otro" do
    turno = Turno.new(hora_inicio: "18:15", hora_fin: "18:45")
    assert_not turno.valid?
  end

  test "no permite un turno que contiene a otro" do
    turno = Turno.new(hora_inicio: "17:00", hora_fin: "21:00")
    assert_not turno.valid?
  end

  test "no permite un turno idéntico a uno existente" do
    turno = Turno.new(hora_inicio: "18:00", hora_fin: "19:00")
    assert_not turno.valid?
  end

  test "permite un turno contiguo (termina justo cuando empieza otro)" do
    turno = Turno.new(hora_inicio: "17:00", hora_fin: "18:00")
    assert turno.valid?
  end

  test "editar un turno no lo compara contra sí mismo" do
    turno = turnos(:one)
    turno.hora_fin = "18:50"
    assert turno.valid?
  end

  test "as_json devuelve las horas como HH:MM" do
    json = turnos(:one).as_json

    assert_equal "18:00", json["hora_inicio"]
    assert_equal "19:00", json["hora_fin"]
  end
end
