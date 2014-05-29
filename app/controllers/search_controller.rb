class SearchController < ApplicationController

  respond_to :json

  def index
    q, type = search_params[:q], search_params[:type]
    respond_with perform_search(q, type).merge(q: q)
  end

  private

  def perform_search(q, type)
    {}.tap do |results|
      case type
      when 'template'
        results[:templates] = Template.recommended.named_like(q)
      else
        results[:remote_images] = Image.search_remote_index(term: q)
        results[:local_images] = Image.local_with_repo_like(q)
        results[:templates] = Template.recommended.named_like(q)
      end
    end
  end

  def search_params
    params.permit(:q, :type)
  end

end
