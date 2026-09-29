class Cancha < ApplicationRecord
  has_many :reservas, dependent: :destroy
  has_one_attached :foto

  validates :nombre, presence: true
  validates :capacidad, numericality: { greater_than: 0 }
  validates :precio, numericality: { greater_than: 0 }

  def foto_url
    return nil unless foto.attached?
    Rails.application.routes.url_helpers.rails_blob_url(foto, only_path: true)
  end

  def as_json(options = {})
    super(options).merge(foto_url: foto_url)
  end
end
