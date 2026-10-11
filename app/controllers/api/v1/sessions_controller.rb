class Api::V1::SessionsController < Api::V1::BaseController
  skip_before_action :authenticate_user!, only: [ :create, :signup ]

  def create
    user = User.find_by(email: params[:email])

    if user&.authenticate(params[:password])
      render json: {
        token: user.api_token,
        user: { id: user.id, name: user.name, email: user.email, role: user.role }
      }, status: :ok
    else
      render json: { error: "Email o contraseña incorrectos" }, status: :unauthorized
    end
  end

  def signup
    user = User.new(signup_params)
    user.role = "cliente"

    if user.save
      render json: {
        token: user.api_token,
        user: { id: user.id, name: user.name, email: user.email, role: user.role }
      }, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # Cierra la sesión rotando el api_token: el token que usaba el cliente
  # deja de ser válido y el próximo login devuelve uno nuevo.
  # OJO: como hay un solo token por user, esto cierra la sesión en todos
  # los dispositivos a la vez.
  def destroy
    current_api_user.regenerate_api_token
    head :no_content
  end

  private

  def signup_params
    params.require(:user).permit(:name, :email, :phone, :password, :password_confirmation)
  end
end
