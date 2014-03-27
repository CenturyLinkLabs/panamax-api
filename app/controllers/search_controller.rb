class SearchController < ApplicationController

  respond_to :json

  def index
    search_results = {}
    search_results[:remote_images] = Docker::Image.search(query={ term: params[:q] })
    search_results[:local_images] = Docker::Image.all
    respond_with search_results
  end

end