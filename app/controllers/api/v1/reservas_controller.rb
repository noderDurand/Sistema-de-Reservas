class Api::V1::ReservasController < Api::V1::BaseController
  def index
    render json: current_api_user.reservas.includes(:cancha, :turno, :pago).order(fecha: :desc)
  end

  def show
    reserva = current_api_user.reservas.find(params[:id])
    render json: reserva.as_json(con_qr: true, base_url: pago_base_url)
  end

  def create
    reserva = current_api_user.reservas.new(reserva_params)
    if reserva.save
      ReservaMailer.confirmation(reserva).deliver_later
      render json: reserva.as_json(con_qr: true, base_url: pago_base_url), status: :created
    else
      render_errors(reserva.errors.full_messages, :unprocessable_entity)
    end
  rescue ActiveRecord::RecordNotUnique
    # Dos requests simultáneos pasaron la validación a la vez: el índice
    # único de la base frenó al segundo.
    render_errors("Cancha ya esta reservada en ese horario", :unprocessable_entity)
  end

  # PATCH /api/v1/reservas/:id/cancelar — solo sobre reservas propias
  # (una ajena da 404 por el rescue_from del BaseController).
  def cancelar
    reserva = current_api_user.reservas.find(params[:id])
    if reserva.cancelar
      render json: reserva
    else
      render_errors(reserva.errors.full_messages, :unprocessable_entity)
    end
  end

  private

  # Host que va dentro del QR. Tiene que ser alcanzable desde el celular que
  # escanea: en desarrollo localhost no sirve, hay que setear PUBLIC_BASE_URL
  # con la IP de la PC (ej. http://192.168.0.10:3000).
  def pago_base_url
    ENV.fetch("PUBLIC_BASE_URL", request.base_url)
  end

  def reserva_params
    params.require(:reserva).permit(:cancha_id, :turno_id, :fecha)
  end
end
