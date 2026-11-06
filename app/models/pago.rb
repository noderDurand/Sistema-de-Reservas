class Pago < ApplicationRecord
  belongs_to :reserva
  # El token va dentro del QR: es lo que identifica el pago al escanearlo.
  # Se genera solo al crear el registro (igual que User#api_token).
  has_secure_token :token

  MODOS = %w[efectivo online].freeze
  ESTADOS = %w[pendiente aprobado].freeze

  validates :estado, inclusion: { in: ESTADOS }
  # Un pago pendiente todavía no tiene fecha: se completa al aprobarse.
  validates :fecha, presence: true, if: :aprobado?
  validates :precio, numericality: { greater_than: 0 }
  validates :modo, inclusion: { in: MODOS }

  def aprobado?
    estado == "aprobado"
  end

  # Pago simulado: se llama cuando alguien escanea el QR. Es idempotente
  # (escanear dos veces no rompe nada) y no deja pagar una reserva cancelada.
  def aprobar
    return true if aprobado?

    if reserva.estado == "cancelada"
      errors.add(:base, "La reserva está cancelada, no se puede pagar")
      return false
    end

    update(estado: "aprobado", fecha: Time.current)
  end

  # URL pública que contiene el QR. base_url es el host que alcanza el celular
  # que escanea (ver pago_base_url en Api::V1::ReservasController).
  def url_de_pago(base_url)
    "#{base_url}/pagos/#{token}"
  end

  # QR como SVG (texto), listo para insertar en el front con v-html / innerHTML.
  def qr_svg(base_url)
    RQRCode::QRCode.new(url_de_pago(base_url)).as_svg(
      module_size: 6, standalone: true, use_path: true, viewbox: true
    )
  end

  # JSON para la API. El QR solo se incluye si se pide (con_qr: true) y el pago
  # sigue pendiente: en el listado de reservas sería peso al pedo.
  def as_json(options = {})
    json = {
      "id" => id, "estado" => estado, "modo" => modo,
      "precio" => precio, "fecha" => fecha
    }
    if options[:con_qr] && options[:base_url] && !aprobado?
      json["pago_url"] = url_de_pago(options[:base_url])
      json["qr_svg"] = qr_svg(options[:base_url])
    end
    json
  end
end
