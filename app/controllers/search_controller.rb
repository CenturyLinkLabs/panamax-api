class SearchController < ApplicationController

  respond_to :json

  def index
    q = params[:q]
    search_results = {q: q}
    search_results[:remote_images] = Docker::Image.search(query={ term: q })
    search_results[:local_images] = images_for_repo_like(q)
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