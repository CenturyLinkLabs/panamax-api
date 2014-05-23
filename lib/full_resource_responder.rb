class FullResourceResponder < ActionController::Responder

  protected

  def display_errors
    controller.render format => resource, :status => :unprocessable_entity
  end

end
