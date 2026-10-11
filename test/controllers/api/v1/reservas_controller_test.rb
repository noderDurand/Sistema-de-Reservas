require "test_helper"

class Api::V1::ReservasControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @headers = { "Authorization" => "Bearer #{@user.api_token}" }
  end

  test "should get index" do
    get api_v1_reservas_url, headers: @headers
    assert_response :success
  end

  test "index sin token devuelve 401" do
    get api_v1_reservas_url
    assert_response :unauthorized
    assert_equal [ "No autorizado" ], response.parsed_body["errors"]
  end

  # --- formato de errores: siempre JSON { errors: [...] } ---

  test "show de una reserva ajena devuelve 404 en formato errors" do
    otro = { "Authorization" => "Bearer #{users(:two).api_token}" }

    get api_v1_reserva_url(reservas(:one)), headers: otro

    assert_response :not_found
    assert_equal [ "Recurso no encontrado" ], response.parsed_body["errors"]
  end

  test "create sin la clave reserva devuelve 400 en JSON" do
    post api_v1_reservas_url, params: { cancha_id: canchas(:one).id }, headers: @headers

    assert_response :bad_request
    assert_equal "application/json", response.media_type
    assert_equal [ "Falta el parámetro 'reserva'" ], response.parsed_body["errors"]
  end

  test "create con JSON mal armado devuelve 400 en JSON" do
    post api_v1_reservas_url, params: '{"reserva": ',
      headers: @headers.merge("Content-Type" => "application/json")

    assert_response :bad_request
    assert_equal "application/json", response.media_type
    assert_equal [ "El cuerpo de la petición no es un JSON válido" ], response.parsed_body["errors"]
  end

  test "should get show" do
    get api_v1_reserva_url(reservas(:one)), headers: @headers
    assert_response :success
  end

  test "should create reserva" do
    assert_difference("Reserva.count") do
      post api_v1_reservas_url,
        params: {
          reserva: {
            cancha_id: canchas(:two).id,
            turno_id: turnos(:one).id,
            fecha: Date.tomorrow + 10.days
          }
        },
        headers: @headers
    end
    assert_response :created
  end

  test "no permite crear una reserva duplicada" do
    post api_v1_reservas_url,
      params: {
        reserva: {
          cancha_id: reservas(:one).cancha_id,
          turno_id: reservas(:one).turno_id,
          fecha: reservas(:one).fecha
        }
      },
      headers: @headers

    assert_response :unprocessable_entity
    assert_includes response.parsed_body["errors"], "Cancha ya esta reservada en ese horario"
  end

  test "no permite crear una reserva en una fecha pasada" do
    assert_no_difference("Reserva.count") do
      post api_v1_reservas_url,
        params: {
          reserva: {
            cancha_id: canchas(:one).id,
            turno_id: turnos(:one).id,
            fecha: Date.yesterday
          }
        },
        headers: @headers
    end

    assert_response :unprocessable_entity
    assert_includes response.parsed_body["errors"], "Fecha no puede ser una fecha pasada"
  end

  # --- JSON ---

  test "index devuelve nombre de cancha y horario del turno" do
    get api_v1_reservas_url, headers: @headers

    reserva = response.parsed_body.find { |r| r["id"] == reservas(:one).id }
    assert_equal canchas(:one).nombre, reserva["cancha"]["nombre"]
    assert_equal "18:00", reserva["turno"]["hora_inicio"]
    assert_equal "19:00", reserva["turno"]["hora_fin"]
    assert_nil reserva["user_id"]
  end

  # --- cancelar ---

  test "cancelar una reserva propia la deja cancelada" do
    patch cancelar_api_v1_reserva_url(reservas(:one)), headers: @headers

    assert_response :success
    assert_equal "cancelada", response.parsed_body["estado"]
    assert_equal "cancelada", reservas(:one).reload.estado
  end

  test "cancelar una reserva ya cancelada devuelve 422" do
    reservas(:one).update!(estado: "cancelada")

    patch cancelar_api_v1_reserva_url(reservas(:one)), headers: @headers

    assert_response :unprocessable_entity
    assert_includes response.parsed_body["errors"], "La reserva ya está cancelada"
  end

  test "cancelar una reserva pasada devuelve 422" do
    reservas(:one).update_column(:fecha, Date.yesterday)

    patch cancelar_api_v1_reserva_url(reservas(:one)), headers: @headers

    assert_response :unprocessable_entity
    assert_equal "pendiente", reservas(:one).reload.estado
  end

  test "no se puede cancelar la reserva de otro usuario" do
    otro = { "Authorization" => "Bearer #{users(:two).api_token}" }

    patch cancelar_api_v1_reserva_url(reservas(:one)), headers: otro

    assert_response :not_found
    assert_equal "pendiente", reservas(:one).reload.estado
  end

  test "cancelar sin token devuelve 401" do
    patch cancelar_api_v1_reserva_url(reservas(:one))
    assert_response :unauthorized
  end
end
