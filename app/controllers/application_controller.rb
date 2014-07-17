class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session

  rescue_from StandardError, with: :handle_exception

  def handle_exception(ex, message=nil, &block)
    logger.error "#{ex.class} - #{ex.message}"
    logger.error "\t#{ex.backtrace.join("\n\t")}"

    message = message.nil? ? ex.message : t(message, default: message)

    block.call(message) if block_given?

    # If we haven't already rendered a response, use default error handling
    # logic
    unless performed?
      render json: { message: message }, status: :internal_server_error
    end
  end
end
