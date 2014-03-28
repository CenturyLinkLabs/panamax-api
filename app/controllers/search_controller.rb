class SearchController < ApplicationController

  respond_to :json

  def index
    search_results = {}
    search_results[:remote_images] = Docker::Image.search(query={ term: params[:q] })
    search_results[:local_images] = images_for_repo_like(params[:q])
    respond_with search_results
  end

  private
  def images_for_repo_like(repo)
    images = Docker::Image.all.map do |image|
               repo_tags = image.info['RepoTags'] || []
               image if repo_tags.any? { |tag| tag =~ /#{repo}/ }
             end
    images.compact
  end
end