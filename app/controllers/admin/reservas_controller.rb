class Admin::ReservasController < Admin::BaseController
  before_action :set_reserva, only: [ :show, :edit, :update ]

  def index
    @reservas = Reserva.includes(:cancha, :turno, :user).order(fecha: :desc)
  end

  def show
  end

  def edit
  end

  def update
    if @reserva.update(reserva_params)
      redirect_to admin_reserva_path(@reserva), notice: "Reserva actualizada"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_reserva
    @reserva = Reserva.find(params[:id])
  end

  def reserva_params
    params.require(:reserva).permit(:estado)
  end
end
