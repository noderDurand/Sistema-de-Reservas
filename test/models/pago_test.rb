require "test_helper"

class PagoTest < ActiveSupport::TestCase
  test "es válido con datos correctos" do
    pago = Pago.new(fecha: Time.current, precio: 5000, modo: "efectivo", reserva: reservas(:one))
    assert pago.valid?
  end

  test "requiere precio mayor a 0" do
    pago = Pago.new(fecha: Time.current, precio: 0, modo: "efectivo", reserva: reservas(:one))
    assert_not pago.valid?
  end

  test "requiere modo válido" do
    pago = Pago.new(fecha: Time.current, precio: 5000, modo: "cheque", reserva: reservas(:one))
    assert_not pago.valid?
  end
end
