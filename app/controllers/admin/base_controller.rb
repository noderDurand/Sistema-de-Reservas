class Admin::BaseController < ApplicationController
    layout "admin"
    before_action :require_admin

    private_class_method

    def require_admin
      unless current_user&.role = "admin"
        redirect_to admin_login_path, alert: "Necesitas iniciar sesion como adminitrador"
      end
    end
end
