require "test_helper"

class Api::V1::SessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
  end

  # --- login ---

  test "login con credenciales correctas devuelve el token" do
    post api_v1_login_url, params: { email: @user.email, password: "password123" }

    assert_response :ok
    body = response.parsed_body
    assert_equal @user.api_token, body["token"]
    assert_equal @user.email, body["user"]["email"]
  end

  test "login con password incorrecta devuelve 401" do
    post api_v1_login_url, params: { email: @user.email, password: "incorrecta" }

    assert_response :unauthorized
    assert_equal [ "Email o contraseña incorrectos" ], response.parsed_body["errors"]
  end

  # --- signup ---

  test "signup crea un cliente aunque se mande role admin" do
    assert_difference("User.count") do
      post api_v1_signup_url, params: {
        user: {
          name: "Nuevo", email: "nuevo@example.com", phone: "1199999999",
          password: "secreta123", password_confirmation: "secreta123", role: "admin"
        }
      }
    end

    assert_response :created
    assert_equal "cliente", response.parsed_body["user"]["role"]
    assert response.parsed_body["token"].present?
  end

  test "signup con email repetido devuelve 422 con errores" do
    assert_no_difference("User.count") do
      post api_v1_signup_url, params: {
        user: { name: "Otro", email: @user.email, password: "secreta123", password_confirmation: "secreta123" }
      }
    end

    assert_response :unprocessable_entity
    assert response.parsed_body["errors"].any?
  end

  # --- logout ---

  test "logout invalida el token anterior" do
    token_viejo = @user.api_token

    delete api_v1_logout_url, headers: { "Authorization" => "Bearer #{token_viejo}" }
    assert_response :no_content
    assert_not_equal token_viejo, @user.reload.api_token

    get api_v1_profile_url, headers: { "Authorization" => "Bearer #{token_viejo}" }
    assert_response :unauthorized
  end

  test "logout sin token devuelve 401" do
    delete api_v1_logout_url
    assert_response :unauthorized
  end

  test "despues del logout el login devuelve el token nuevo" do
    delete api_v1_logout_url, headers: { "Authorization" => "Bearer #{@user.api_token}" }
    post api_v1_login_url, params: { email: @user.email, password: "password123" }

    assert_equal @user.reload.api_token, response.parsed_body["token"]
  end

  # --- CORS ---

  test "preflight CORS desde el origen del front es aceptado" do
    process :options, "/api/v1/reservas", headers: {
      "Origin" => "http://localhost:5173",
      "Access-Control-Request-Method" => "POST",
      "Access-Control-Request-Headers" => "Authorization, Content-Type"
    }

    assert_equal "http://localhost:5173", response.headers["Access-Control-Allow-Origin"]
  end

  test "CORS no habilita origenes desconocidos" do
    get api_v1_canchas_url, headers: { "Origin" => "http://sitio-malicioso.com" }

    assert_nil response.headers["Access-Control-Allow-Origin"]
  end
end
