class ServicesController < ApplicationController
  respond_to :json

  def index
    respond_with app.services
  end

  def show
    respond_with app.services.find(params[:id])
  end

  def update
    service = app.services.find(params[:id])
    if service.update_with_relationships(service_update_params)
      service.restart
    end
    respond_with service
  end

  def journal
    respond_with app.services.find(params[:id]).journal(params[:cursor])
  end

  def destroy
    respond_with app.services.find(params[:id]).destroy
  end

  def create
    service = app.add_service(service_create_params)
    if service
      app.restart
    end
    render json: service
  end

  def start
    service = app.services.find(params[:id])
    if service && !service.started?
      service.start
    end
    render json: service
  end

  private

  def app
    @app ||= App.find(params[:app_id])
  end

  def service_update_params
    params.permit(
      :name,
      :description,
      :ports => [[:host_interface, :host_port, :container_port, :proto]],
      :expose => [],
      :volumes => [[:host_path, :container_path]],
      :links => [[:service_id, :alias]]
    ).tap do |whitelisted|
      whitelisted[:environment] = params[:environment]
    end
  end

  def service_create_params
    params.permit(
      :name,
      :description,
      :from,
      :categories => [[:id]],
      :ports => [[:host_interface, :host_port, :container_port, :proto]],
      :expose => [],
      :volumes => [[:host_path, :container_path]],
      :links => [[:service_id, :alias]]
    ).tap do |whitelisted|
      whitelisted[:environment] = params[:environment]
    end
  end

end
