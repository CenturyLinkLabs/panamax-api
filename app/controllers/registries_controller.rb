class RegistriesController < ApplicationController
  respond_to :json

  def create
    respond_with Registry.create(registry_params)
  end

  def update
    registry = Registry.find(params[:id])
    registry.update(registry_params)
    respond_with registry
  end

  def destroy
    respond_with Registry.destroy(params[:id])
  end

  private

  def registry_params
    params.permit(:name, :endpoint_url)
  end
end
