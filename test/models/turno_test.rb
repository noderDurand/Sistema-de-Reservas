require "test_helper"

class TurnoTest < ActiveSupport::TestCase
  test "es válido con datos correctos" do
    turno = Turno.new(hora_inicio: "18:00", hora_fin: "19:00")
    assert turno.valid?
  end

  test "hora_fin debe ser posterior a hora_inicio" do
    turno = Turno.new(hora_inicio: "19:00", hora_fin: "18:00")
    assert_not turno.valid?
    assert_includes turno.errors[:hora_fin], "Debe ser posterior a la hora de inicio"
  end
end
