require "test_helper"

class Api::V1::ReservasControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get api_v1_reservas_index_url
    assert_response :success
  end

  test "should get show" do
    get api_v1_reservas_show_url
    assert_response :success
  end

  test "should get create" do
    get api_v1_reservas_create_url
    assert_response :success
  end
end
