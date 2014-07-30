class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session

  respond_to :json

  rescue_from StandardError, with: :handle_exception

  rescue_from Docker::Error::ServerError do |ex|
    handle_exception(ex, :docker_connection_error)
  end

  def handle_exception(ex, message=nil, &block)
    log_message = "\n#{ex.class} (#{ex.message}):\n"
    log_message << "  " << ex.backtrace.join("\n  ") << "\n\n"
    logger.error(log_message)

    message = message.nil? ? ex.message : t(message, default: message)

    block.call(message) if block_given?

    # If we haven't already rendered a response, use default error handling
    # logic
    unless performed?
      render json: { message: message }, status: :internal_server_error
    end
  end
end
