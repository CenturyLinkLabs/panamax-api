class SearchController < ApplicationController

  using ArrayItemWrapper

  def index
    q, limit, type = search_params.values_at(:q, :limit, :type)
    respond_with perform_search(q, limit, type).merge(q: q)
  end

  private

  def perform_search(q, limit, *types)
    types = %w(template local_image remote_image) if types.compact.empty?
    {}.tap do |results|
      results[:templates] = wrapped_templates(q, limit) if types.include? 'template'
      results[:local_images] = wrapped_local_images(q, limit) if types.include? 'local_image'

      if types.include? 'remote_image'
        results[:remote_images], results[:errors] = wrapped_remote_images(q, limit)
      end
    end
  end

  def search_params
    # Coerce limit to an integer
    params[:limit] = params[:limit].to_i if params[:limit].present?

    params.permit(:q, :type, :limit)
  end

  def wrapped_templates(q, limit)
    Template.search(q, limit).wrap(TemplateSerializer)
  end

  def wrapped_local_images(q, limit)
    LocalImage.search(q, limit).wrap(LocalImageSearchResultSerializer)
  end

  def wrapped_remote_images(q, limit)
    images, errors = Registry.search(q, limit)
    return images.wrap(RemoteImageSearchResultSerializer), errors
  end
end
