class SearchController < ApplicationController

  respond_to :json

  def index
    q, limit, type = search_params.values_at(:q, :limit, :type)
    respond_with perform_search(q, limit, type).merge(q: q)
  end

  private

  def perform_search(q, limit, *types)
    types = %w(template local_image remote_image) if types.compact.empty?
    {}.tap do |results|
      results[:templates] = wrapped_templates(q, limit) if types.include? 'template'
      results[:local_images] = Image.local_with_repo_like(q, limit) if types.include? 'local_image'
      results[:remote_images] = Image.search_remote_index(q, limit) if types.include? 'remote_image'
    end
  end

  def search_params
    # Coerce limit to an integer
    params[:limit] = params[:limit].to_i if params[:limit].present?

    params.permit(:q, :type, :limit)
  end

  def wrapped_templates(q, limit)
    Template.search(q, limit).map { |t| TemplateSerializer.new(t) }
  end

end
