class Admin::TurnosController < Admin::BaseController
  before_action :set_turno, only: [ :show, :edit, :update, :destroy ]

  def index
    @turnos = Turno.all
  end

  def show
  end

  def new
    @turno = Turno.new
  end

  def create
    @turno = Turno.new(turno_params)
    if @turno.save
      redirect_to admin_turno_path(@turno), notice: "Turno creado correctamente"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @turno.update(turno_params)
      redirect_to admin_turno_path(@turno), notice: "Turno actualizado"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @turno.destroy
    redirect_to admin_turnos_path, notice: "Turno eliminado"
  end

  private

  def set_turno
    @turno = Turno.find(params[:id])
  end

  def turno_params
    params.require(:turno).permit(:hora_inicio, :hora_fin)
  end
end
