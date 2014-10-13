class RegistriesController < ApplicationController
  respond_to :json

  def index
    headers['Total-Count'] = Registry.count
    respond_with Registry.limit(params[:limit].presence)
  end

  def create
    respond_with Registry.create(registry_params)
  end

  def update
    registry = Registry.find(params[:id])
    registry.update(registry_params)
    respond_with registry
  end

  def show
    respond_with(Registry.find(params[:id]))
  end

  def destroy
    respond_with Registry.destroy(params[:id])
  end

  private

  def registry_params
    params.permit(:name, :endpoint_url)
  end
end
