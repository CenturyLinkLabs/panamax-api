class SearchController < ApplicationController

  respond_to :json

  def index
    q, type = search_params[:q], search_params[:type]
    respond_with perform_search(q, type).merge(q: q)
  end

  private

  def perform_search(q, *types)
    types = %w(template local_image remote_image) if types.compact.empty?
    {}.tap do |results|
      results[:templates] = Template.recommended.named_like(q) if types.include? 'template'
      results[:local_images] = Image.local_with_repo_like(q) if types.include? 'local_image'
      results[:remote_images] = Image.search_remote_index(term: q) if types.include? 'remote_image'
    end
  end

  def search_params
    params.permit(:q, :type)
  end

end
