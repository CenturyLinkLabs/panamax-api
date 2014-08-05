class LocalImagesController < ApplicationController

  def index
    images = LocalImage.all
    total_count = images.size
    headers['Total-Count'] = total_count
    respond_with images.take(index_params[:limit] || total_count)
  end

  def show
    image = LocalImage.find_by_id_or_name(params[:id])

    if image
      respond_with image
    else
      head status: :not_found
    end
  end

  def destroy
    respond_with LocalImage.destroy(params[:id])
  rescue Excon::Errors::Conflict => ex
    handle_exception(ex, :docker_rmi_error)
  end

  private

  def index_params
    params[:limit] = params[:limit].to_i if params[:limit].present?
    params.permit(:limit)
  end
end
