require "test_helper"

class Api::V1::CanchasControllerTest < ActionDispatch::IntegrationTest
  # Fixtures: turno one = 18:00-19:00, two = 19:00-20:00.
  # reservas(:one) ocupa cancha one + turno one en Date.current + 7.

  test "index es público" do
    get api_v1_canchas_url
    assert_response :success
  end

  test "turnos_disponibles excluye los turnos ya reservados" do
    get turnos_disponibles_api_v1_cancha_url(canchas(:one)), params: { fecha: reservas(:one).fecha.to_s }

    assert_response :success
    assert_equal [ turnos(:two).id ], response.parsed_body.map { |t| t["id"] }
  end

  test "turnos_disponibles incluye turnos de reservas canceladas" do
    reservas(:one).update!(estado: "cancelada")

    get turnos_disponibles_api_v1_cancha_url(canchas(:one)), params: { fecha: reservas(:one).fecha.to_s }

    assert_equal [ turnos(:one).id, turnos(:two).id ], response.parsed_body.map { |t| t["id"] }
  end

  test "turnos_disponibles de hoy no incluye turnos que ya empezaron" do
    travel_to Time.zone.local(2026, 10, 11, 18, 30) do
      get turnos_disponibles_api_v1_cancha_url(canchas(:one)), params: { fecha: "2026-10-11" }

      assert_response :success
      assert_equal [ turnos(:two).id ], response.parsed_body.map { |t| t["id"] }
    end
  end

  test "turnos_disponibles sin fecha devuelve 400" do
    get turnos_disponibles_api_v1_cancha_url(canchas(:one))
    assert_response :bad_request
  end

  test "turnos_disponibles con fecha inválida devuelve 400" do
    get turnos_disponibles_api_v1_cancha_url(canchas(:one)), params: { fecha: "2026-02-30" }

    assert_response :bad_request
    assert_equal [ "Fecha inválida, el formato es YYYY-MM-DD" ], response.parsed_body["errors"]
  end

  test "turnos_disponibles con fecha pasada devuelve 422" do
    get turnos_disponibles_api_v1_cancha_url(canchas(:one)), params: { fecha: Date.yesterday.to_s }
    assert_response :unprocessable_entity
  end

  test "turnos_disponibles de una cancha inexistente devuelve 404" do
    get turnos_disponibles_api_v1_cancha_url(id: 999_999), params: { fecha: Date.tomorrow.to_s }
    assert_response :not_found
  end
end
