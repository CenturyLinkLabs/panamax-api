class AppsController < ApplicationController
  respond_to :json

  def index
    respond_with App.all
  end

  def show
    respond_with App.find(params[:id])
  end

  def create
    @app = if params[:template_id]
             App.create_from_template(Template.find(params[:template_id]))
           else
             App.create_from_image(
                 image: params[:image],
                 tag: params[:tag],
                 links: params[:links],
                 ports: params[:ports],
                 expose: params[:expose],
                 environment: params[:environment],
                 volumes: params[:volumes]
             )
           end

    AppExecutor.run(@app)
    respond_with @app
  end


end
