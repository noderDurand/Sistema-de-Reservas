class Api::V1::ReservasController < Api::V1::BaseController
  def index
    render json: current_api_user.reservas.includes(:cancha, :turno)
  end

  def show
    reserva = current_api_user.reservas.find(params[:id])
    render json: reserva
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Reserva no encontrada" }, status: :not_found
  end

  def create
    reserva = current_api_user.reservas.new(reserva_params)
    if reserva.save
      render json: reserva, status: :created
    else
      render json: { errors: reserva.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def reserva_params
    params.require(:reserva).permit(:cancha_id, :turno_id, :fecha)
  end
end
