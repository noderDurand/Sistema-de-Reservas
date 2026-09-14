class Admin::SessionsController < ApplicationController
  layout "admin"
  def new
  end

  def create
    user = User.find_by(email: params[:email])

    if user&.authenticate(params[:password]) && user.role == "admin"
      session[:user_id] = user.id
      redirect_to admin_root_path, notice: "Bienvenido/a #{user.name}"
    else
      flash.now[:alert] = "Email o contraseña incorrectos, o no tenes permisos de administrador"
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to admin_login_path, notice: "Sesion cerrada"
  end
end
