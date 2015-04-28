class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session
  rescue_from ActionController::RoutingError, with: :record_not_found
  before_filter :check_api_key

  def not_found
  	raise ActionController::RoutingError.new('Not Found')
  end

  def record_not_found
  	render json: {msg: "Fail!"}, status: 404
  end

  def check_api_key
    if params[:api_key] != Rails.application.config.api_key
      render json: {msg: "Unauthorized operation!"}, status: 401
    end
  end
end
