require "test_helper"

class Admin::CanchasControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get admin_canchas_index_url
    assert_response :success
  end

  test "should get show" do
    get admin_canchas_show_url
    assert_response :success
  end

  test "should get new" do
    get admin_canchas_new_url
    assert_response :success
  end

  test "should get edit" do
    get admin_canchas_edit_url
    assert_response :success
  end
end
