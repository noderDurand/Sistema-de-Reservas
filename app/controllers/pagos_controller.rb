# Destino del QR del pago simulado. Es público (lo abre el celular, no tiene
# el token de la API): lo único que "autentica" es el token del pago, que es
# largo y aleatorio. Al escanear el QR el pago queda aprobado.
class PagosController < ApplicationController
  def show
    @pago = Pago.includes(reserva: [ :cancha, :turno ]).find_by!(token: params[:token])
    @aprobado = @pago.aprobar
  end
end
