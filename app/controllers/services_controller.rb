class ServicesController < ApplicationController
  respond_to :json

  def index
    respond_with app.services
  end

  def show
    respond_with app.services.find(params[:id])
  end

  def create

  end

  private
  def app
    @app ||= App.find(params[:app_id])
  end

end