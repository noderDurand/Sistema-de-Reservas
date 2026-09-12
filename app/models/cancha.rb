class Cancha < ApplicationRecord
  has_many :reservas, dependent: :destroy

  validates :nombre, presence: true
  validates :capacidad, numericality: { greater_than: 0 }
  validates :precio, numericality: { greater_than: 0 }
end
