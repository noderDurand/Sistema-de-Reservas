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
  end
end
