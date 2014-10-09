class RepositoriesController < ApplicationController

  def show
    image = if params[:local] == 'true'
              LocalImage.find_by_name(params[:id])
            else
              registry = Registry.find_by_id(params[:registry_id].to_i) || Registry.docker_hub
              registry.find_image_by_name(params[:id])
            end

    respond_with image, serializer: RepositorySerializer
  rescue PanamaxAgent::ConnectionError => ex
    handle_exception(ex, :registry_connection_error)
  end
end
