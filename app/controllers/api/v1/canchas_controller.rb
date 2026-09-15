class Api::V1::CanchasController < Api::V1::BaseController
  skip_before_action :authenticate_user!, only: [ :index, :show, :turnos_disponibles ]
  def index
    render json: Cancha.all
  end

  def show
    render json: Cancha.find(params[:id])
  end

  def turnos_disponibles
    cancha = Cancha.find(params[:id])
    fecha = params[:fecha]

    if fecha.blank?
      return render json: { error: "debes indicar una fecha (?fecha=YYYY-MM-DD)" }, status: :bad_request
    end

    ocupados_ids = Reserva.where(cancha: cancha, fecha: fecha).where.not(estado: "cancelada").pluck(:turno_id)

    render json: Turno.where.not(id: ocupados_ids)
  end
end
