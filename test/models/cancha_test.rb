require "test_helper"

class CanchaTest < ActiveSupport::TestCase
  test "es válida con datos correctos" do
    cancha = Cancha.new(nombre: "Cancha 3", capacidad: 10, precio: 5000)
    assert cancha.valid?
  end

  test "requiere nombre" do
    cancha = Cancha.new(nombre: nil, capacidad: 10, precio: 5000)
    assert_not cancha.valid?
  end

  test "requiere capacidad mayor a 0" do
    cancha = Cancha.new(nombre: "Cancha 3", capacidad: 0, precio: 5000)
    assert_not cancha.valid?
  end

  test "requiere precio mayor a 0" do
    cancha = Cancha.new(nombre: "Cancha 3", capacidad: 10, precio: 0)
    assert_not cancha.valid?
  end
end
