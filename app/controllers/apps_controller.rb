class AppsController < ApplicationController
  respond_to :json

  def index
    respond_with App.all
  end

  def show
    respond_with App.find(params[:id])
  end

  def update
    app = App.find(params[:id])
    app.update(app_update_params)
    respond_with app
  end

  def destroy
    respond_with App.find(params[:id]).destroy
  end

  def create
    app = AppBuilder.create(app_params)

    if app.valid?
      app.run
    else
      logger.error("app validation failed: #{app.errors.to_hash}")
    end

    respond_with app
  rescue => ex
    logger.error("app creation failed: #{ex.message}")
    app.try(:destroy)
    render json: { errors: ex.message }, status: :internal_server_error
  end

  def journal
    respond_with App.find(params[:id]).journal(params[:cursor])
  end

  def rebuild
    respond_with App.find(params[:id]).restart
  end

  private

  def app_update_params
    params.permit(
      :id,
      :name,
      :from,
      :description,
      :categories
    )
  end

  def app_params
    params.permit(
      :template_id,
      :image,
      :type,
      links: [[:service, :alias]],
      environment: [[:variable, :value, :required]],
      command: [],
      ports: [[:host_interface, :host_port, :container_port, :proto]],
      expose: [],
      volumes: [[:host_path, :container_path]]
    )
  end
end
