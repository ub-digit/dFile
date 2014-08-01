class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  rescue_from ActionController::RoutingError, with: :record_not_found

  def not_found
  	raise ActionController::RoutingError.new('Not Found')
  end

  def record_not_found
  	render json: {msg: "Fail!"}, status: 404
  end
end
