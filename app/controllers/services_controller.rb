class ServicesController < ApplicationController

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
  rescue PanamaxAgent::ConnectionError => ex
    handle_exception(ex, :fleet_connection_error)
  end

  def update
    restart = params[:restart] != 'false'
    service = app.services.find(params[:id])
    service.update_with_relationships(service_params) && app.restart if restart
    respond_with service
  rescue PanamaxAgent::ConnectionError => ex
    handle_exception(ex, :fleet_connection_error)
  end

  def destroy
    respond_with app.services.find(params[:id]).destroy
  end

  def journal
    respond_with app.services.find(params[:id]).journal(params[:cursor])
  rescue PanamaxAgent::ConnectionError => ex
    handle_exception(ex, :journal_connection_error)
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
      :command,
      categories: [[:id, :position]],
      ports: [[:host_interface, :host_port, :container_port, :proto]],
      expose: [],
      volumes: [[:host_path, :container_path]],
      volumes_from: [[:service_id]],
      links: [[:service_id, :alias]],
      environment: [[:variable, :value, :required]]
    )
  end

  def service_create_params
    service_params(:from)
  end

end
