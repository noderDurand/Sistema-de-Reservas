require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "es válido con datos correctos" do
    user = User.new(name: "Juan", email: "nuevo@example.com", phone: "123",
                     password: "password123", password_confirmation: "password123")
    assert user.valid?
  end

  test "requiere email único" do
    user = User.new(name: "Otro", email: users(:one).email, phone: "123",
                     password: "password123", password_confirmation: "password123")
    assert_not user.valid?
  end

  test "requiere email con formato válido" do
    user = User.new(name: "Juan", email: "no-es-un-email", phone: "123",
                     password: "password123", password_confirmation: "password123")
    assert_not user.valid?
  end

  test "por defecto el role es cliente" do
    user = User.new(name: "Juan", email: "nuevo2@example.com", phone: "123",
                     password: "password123", password_confirmation: "password123")
    user.valid?
    assert_equal "cliente", user.role
  end

  test "genera api_token al crear" do
    user = User.create!(name: "Juan", email: "nuevo3@example.com", phone: "123",
                         password: "password123", password_confirmation: "password123")
    assert_not_nil user.api_token
  end
end
