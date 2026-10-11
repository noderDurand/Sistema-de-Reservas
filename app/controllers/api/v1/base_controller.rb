class Api::V1::BaseController < ApplicationController
    skip_before_action :verify_authenticity_token
    before_action :authenticate_user!
    rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
    # Body sin la clave esperada (ej. POST /reservas sin "reserva") o con
    # JSON mal armado: sin esto Rails responde 400 pero con una página HTML.
    rescue_from ActionController::ParameterMissing, with: :render_parameter_missing
    rescue_from ActionDispatch::Http::Parameters::ParseError, with: :render_json_invalido

    private

    # Formato único de error de toda la API: { errors: ["mensaje", ...] },
    # sea cual sea el código HTTP. Así el front siempre lee data.errors.
    def render_errors(mensajes, status)
        render json: { errors: Array(mensajes) }, status: status
    end

    def authenticate_user!
        token = request.headers["Authorization"]&.split(" ")&.last
        @current_api_user = token.present? ? User.find_by(api_token: token) : nil
        render_errors("No autorizado", :unauthorized) unless @current_api_user
    end

    def current_api_user
        @current_api_user
    end

    def render_not_found
        render_errors("Recurso no encontrado", :not_found)
    end

    def render_parameter_missing(exception)
        render_errors("Falta el parámetro '#{exception.param}'", :bad_request)
    end

    def render_json_invalido
        render_errors("El cuerpo de la petición no es un JSON válido", :bad_request)
    end
end
