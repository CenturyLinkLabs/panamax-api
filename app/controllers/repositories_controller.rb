class RepositoriesController < ApplicationController

  respond_to :json

  def list_tags
    respond_with registry_client.list_repository_tags(params[:repository])
  end

  private

  def registry_client
    PanamaxAgent.registry_client
  end
end
