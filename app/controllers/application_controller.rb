class ApplicationController < ActionController::API
  rescue_from ActionController::ParameterMissing do |e|
    render json: {
      errors: {
        e.param => ["é obrigatório"]
      }
    }, status: :bad_request
  end
end
