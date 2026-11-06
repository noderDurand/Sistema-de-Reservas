require "test_helper"

class Admin::ReservasControllerTest < ActionDispatch::IntegrationTest
  setup do
    # users(:two) es el admin de los fixtures
    post admin_login_url, params: { email: "admin@example.com", password: "password123" }
  end

  test "el listado muestra el estado del pago de cada reserva" do
    get admin_reservas_url

    assert_response :success
    assert_select "th", "Pago"
    assert_select "td .badge", text: "aprobado"
    assert_select "td .badge", text: "pendiente"
  end

  test "el detalle muestra el pago" do
    pagos(:two).aprobar

    get admin_reserva_url(reservas(:two))

    assert_response :success
    assert_select "dt", "Pago"
    assert_select "dd .badge", text: "aprobado"
  end
end
