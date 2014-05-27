class RepositoriesController < ApplicationController

  respond_to :json

  def list_tags
    @repo = params[:repository]
    if params[:local_image] == 'true'
      tags = list_local_tags
    else
      tags = list_remote_tags
    end
    respond_with tags
  end

  private

  def list_remote_tags
    tag_list = registry_client.list_repository_tags(@repo)
    tag_list.map { |t| t['name'] }
  end

  def list_local_tags
    images = Image.find_local_for(@repo)
    images.map { |i| i.info['RepoTags'].first.split(':').last }
  end

  def registry_client
    PanamaxAgent.registry_client
  end
end
