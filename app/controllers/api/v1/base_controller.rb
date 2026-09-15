class Api::V1::BaseController < ApplicationController
    skip_before_action :verify_authenticity_token
    before_action :authenticate_user!
    rescue_from ActiveRecord::RecordNotFound, with: :render_not_found

    private

    def authenticate_user!
        token = request.headers["Authorization"]&.split(" ")&.last
        @current_api_user = token.present? ? User.find_by(api_token: token) : nil
        render json: { error: "No autorizado" }, status: :unauthorized unless @current_api_user
    end

    def current_api_user
        @current_api_user
    end

    def render_not_found
        render json: { error: "Recurso no encontrado" }, status: :not_found
    end
end
