class Api::V1::ProfilesController < Api::V1::BaseController
  def show
    render json: {
      id: current_api_user.id,
      name: current_api_user.name,
      email: current_api_user.email,
      phone: current_api_user.phone,
      role: current_api_user.role
    }
  end
end
