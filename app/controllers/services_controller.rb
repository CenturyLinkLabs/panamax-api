class ServicesController < ApplicationController
  respond_to :json

  def index
    respond_with app.services
  end

  def show
    respond_with app.services.find(params[:id])
  end

  def create
    service = app.add_service(service_create_params)
    app.restart if service
    respond_with app, service
  end

  def update
    service = app.services.find(params[:id])
    service.update_with_relationships(service_params) && app.restart
    respond_with service
  end

  def destroy
    respond_with app.services.find(params[:id]).destroy
  end

  def journal
    respond_with app.services.find(params[:id]).journal(params[:cursor])
  end

  private

  def app
    @app ||= App.find(params[:app_id])
  end

  def service_params(extras=nil)
    params.permit(
      *extras,
      :name,
      :description,
      :type,
      categories: [[:id, :position]],
      ports: [[:host_interface, :host_port, :container_port, :proto]],
      expose: [],
      volumes: [[:host_path, :container_path]],
      links: [[:service_id, :alias]]
    ).tap do |whitelisted|
      whitelisted[:environment] = params[:environment]
    end
  end

  def service_create_params
    service_params(:from)
  end

end
