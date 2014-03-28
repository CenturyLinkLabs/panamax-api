class SearchController < ApplicationController

  respond_to :json

  def index
    search_results = {}
    search_results[:remote_images] = Docker::Image.search(query={ term: params[:q] })
    search_results[:local_images] = images_with_repository(params[:q])
    respond_with search_results
  end

  private
  def images_with_repository(repo)
    Docker::Image.all.map { |image| image if image.info['Repository'] =~ /#{params[:q]}/ }.compact
  end
end