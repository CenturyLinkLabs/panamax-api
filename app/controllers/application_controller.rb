class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session

  # Use our custom responder which will return the full model representation
  # when errors occur (the Rails default is to simply return the errors)
  self.responder = FullResourceResponder
end
