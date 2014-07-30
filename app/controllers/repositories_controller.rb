class RepositoriesController < ApplicationController

  def show
    image = (params[:local] == 'true' ? LocalImage : RemoteImage)
      .find_by_name(params[:id])

    respond_with image, serializer: RepositorySerializer
  rescue PanamaxAgent::ConnectionError => ex
    handle_exception(ex, :registry_connection_error)
  end
end
