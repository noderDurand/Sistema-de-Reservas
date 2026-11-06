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

  # --- pago simulado con QR ---

  test "un pago pendiente es válido sin fecha, uno aprobado no" do
    pago = Pago.new(precio: 5000, modo: "online", estado: "pendiente", reserva: reservas(:one))
    assert pago.valid?

    pago.estado = "aprobado"
    assert_not pago.valid?
  end

  test "requiere estado válido" do
    pago = Pago.new(precio: 5000, modo: "online", estado: "pagado", reserva: reservas(:one))
    assert_not pago.valid?
  end

  test "no puede haber dos pagos para la misma reserva" do
    assert_raises(ActiveRecord::RecordNotUnique) do
      Pago.create!(precio: 5000, modo: "online", reserva: reservas(:one))
    end
  end

  test "aprobar pasa el pago a aprobado y guarda la fecha" do
    pago = pagos(:two)

    assert pago.aprobar
    assert_equal "aprobado", pago.reload.estado
    assert pago.fecha.present?
  end

  test "aprobar es idempotente" do
    pago = pagos(:two)
    pago.aprobar
    fecha = pago.reload.fecha

    assert pago.aprobar
    assert_equal fecha, pago.reload.fecha
  end

  test "no se puede aprobar el pago de una reserva cancelada" do
    pago = pagos(:two)
    pago.reserva.update!(estado: "cancelada")

    assert_not pago.aprobar
    assert_equal "pendiente", pago.reload.estado
    assert_includes pago.errors[:base], "La reserva está cancelada, no se puede pagar"
  end
end
