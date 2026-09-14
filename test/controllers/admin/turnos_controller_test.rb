require "test_helper"

class Admin::TurnosControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get admin_turnos_index_url
    assert_response :success
  end

  test "should get show" do
    get admin_turnos_show_url
    assert_response :success
  end

  test "should get new" do
    get admin_turnos_new_url
    assert_response :success
  end

  test "should get edit" do
    get admin_turnos_edit_url
    assert_response :success
  end
end
