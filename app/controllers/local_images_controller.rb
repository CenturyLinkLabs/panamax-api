class LocalImagesController < ApplicationController
  respond_to :json

  def index
    respond_with LocalImage.all
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
  end
end
