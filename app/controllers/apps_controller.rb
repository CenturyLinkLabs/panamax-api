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
             App.create_from_image(image_create_params)
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


  private

  def image_create_params
    params.permit(:image,
                  :tag,
                  links: [[:service, :alias]],
                  ports: [[:host_interface, :host_port, :container_port, :proto]],
                  expose: [],
                  volumes: [[:host_path, :container_path]]
                 ).tap do |whitelisted|
                    whitelisted[:environment] = params[:environment]
                  end
  end

end
