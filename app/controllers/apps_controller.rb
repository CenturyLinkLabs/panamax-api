class AppsController < ApplicationController
  respond_to :json

  def index
    respond_with App.all
  end

  def show
    respond_with App.find(params[:id])
  end

  def create
    if params[:template_id]
      App.create_from_template(Template.find(params[:template_id]))
    else
      App.create_from_image(image_create_params)
    end

    render nothing: true
  end

  private
  def image_create_params
    params.permit(:image, :links, :ports, :expose, :environment, :volumes)
  end

end