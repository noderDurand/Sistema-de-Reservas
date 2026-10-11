class Api::V1::ReservasController < Api::V1::BaseController
  def index
    render json: current_api_user.reservas.includes(:cancha, :turno).order(fecha: :desc)
  end

  def show
    reserva = current_api_user.reservas.find(params[:id])
    render json: reserva
  end

  def create
    reserva = current_api_user.reservas.new(reserva_params)
    if reserva.save
      ReservaMailer.confirmation(reserva).deliver_later
      render json: reserva, status: :created
    else
      render_errors(reserva.errors.full_messages, :unprocessable_entity)
    end
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

  def reserva_params
    params.require(:reserva).permit(:cancha_id, :turno_id, :fecha)
  end
end
