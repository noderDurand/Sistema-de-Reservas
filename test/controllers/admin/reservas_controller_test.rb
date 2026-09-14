require "test_helper"

class Admin::ReservasControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get admin_reservas_index_url
    assert_response :success
  end

  test "should get show" do
    get admin_reservas_show_url
    assert_response :success
  end

  test "should get edit" do
    get admin_reservas_edit_url
    assert_response :success
  end
end
