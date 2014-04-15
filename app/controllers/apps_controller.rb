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

    if @app.valid?
      AppExecutor.run(@app)
      render json: @app
    else
      render json: @app, status: :unprocessable_entity
    end
  rescue => ex
    logger.error("app creation failed: #{ex.message}")
    @app.destroy
    @app.errors[:base] << ex.message
    render json: @app, status: :unprocessable_entity
  end


end
