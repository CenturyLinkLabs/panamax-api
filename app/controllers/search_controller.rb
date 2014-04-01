class SearchController < ApplicationController

  respond_to :json

  def index
    q = params[:q]
    search_results = {q: q}
    search_results[:remote_images] = Image.search_remote_index(term: q)
    search_results[:local_images] = Image.local_with_repo_like(q)
    search_results[:template] = Template.recommended.named_like(q).first
    respond_with search_results
  end

end