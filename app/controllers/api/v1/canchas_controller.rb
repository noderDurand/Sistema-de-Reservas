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

    if params[:fecha].blank?
      return render json: { error: "debes indicar una fecha (?fecha=YYYY-MM-DD)" }, status: :bad_request
    end

    fecha = parsear_fecha(params[:fecha])
    if fecha.nil?
      return render json: { error: "fecha inválida, el formato es YYYY-MM-DD" }, status: :bad_request
    end

    if fecha < Date.current
      return render json: { error: "no se puede consultar una fecha pasada" }, status: :unprocessable_entity
    end

    ocupados_ids = Reserva.where(cancha: cancha, fecha: fecha).where.not(estado: "cancelada").pluck(:turno_id)
    disponibles = Turno.where.not(id: ocupados_ids).order(:hora_inicio).reject { |turno| turno.empezado_en?(fecha) }

    render json: disponibles
  end

  private

  def parsear_fecha(valor)
    Date.strptime(valor, "%Y-%m-%d")
  rescue Date::Error
    nil
  end
end
