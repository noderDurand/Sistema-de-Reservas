require "test_helper"

class PagosControllerTest < ActionDispatch::IntegrationTest
  test "escanear el QR aprueba el pago sin necesitar token de API" do
    get pago_publico_url(token: pagos(:two).token)

    assert_response :success
    assert_includes response.body, "Pago aprobado"
    assert_equal "aprobado", pagos(:two).reload.estado
    assert_equal "confirmada", reservas(:two).reload.estado
  end

  test "escanear dos veces sigue mostrando pago aprobado" do
    2.times { get pago_publico_url(token: pagos(:two).token) }

    assert_response :success
    assert_includes response.body, "Pago aprobado"
  end

  test "con la reserva cancelada no aprueba el pago" do
    pagos(:two).reserva.update!(estado: "cancelada")

    get pago_publico_url(token: pagos(:two).token)

    assert_includes response.body, "No se pudo aprobar"
    assert_equal "pendiente", pagos(:two).reload.estado
    assert_equal "cancelada", reservas(:two).reload.estado
  end

  test "token inexistente devuelve 404" do
    get pago_publico_url(token: "no-existe")
    assert_response :not_found
  end

  test "escanear un QR vencido no aprueba el pago y muestra el motivo" do
    travel_to pagos(:two).reserva.created_at + 16.minutes do
      get pago_publico_url(token: pagos(:two).token)
    end

    assert_includes response.body, "venció por falta de pago"
    assert_equal "pendiente", pagos(:two).reload.estado
    assert_equal "cancelada", reservas(:two).reload.estado
  end
end
