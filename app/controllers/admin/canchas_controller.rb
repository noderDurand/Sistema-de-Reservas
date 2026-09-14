class Admin::CanchasController < Admin::BaseController
  before_action :set_cancha, only: [ :show, :edit, :update, :destroy ]

  def index
    @canchas = Cancha.all
  end

  def show
  end

  def new
    @cancha = Cancha.new
  end

  def create
    @cancha = Cancha.new(cancha_params)
    if @cancha.save
      redirect_to admin_cancha_path(@cancha), notice: "Cancha creada correctamente"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @cancha.update(cancha_params)
      redirect_to admin_cancha_path(@cancha), notice: "Cancha actualizada"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @cancha.destroy
    redirect_to admin_canchas_path, notice: "Cancha eliminada"
  end

  private

  def set_cancha
    @cancha = Cancha.find(params[:id])
  end

  def cancha_params
    params.require(:cancha).permit(:nombre, :capacidad, :precio)
  end
end
