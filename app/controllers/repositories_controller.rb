class RepositoriesController < ApplicationController

  respond_to :json

  def list_tags
    repo = params[:repository]
    if params[:local_image] == 'true'
      image = LocalImage.find_by_name(repo)
    else
      image = RemoteImage.find_by_name(repo)
    end
    respond_with image.tags
  rescue PanamaxAgent::ConnectionError => ex
    handle_exception(ex, :registry_connection_error)
  end

end
