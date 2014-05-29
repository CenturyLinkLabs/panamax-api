class TemplatesController < ApplicationController
  respond_to :json

  def index
    respond_with Template.all
  end

  def show
    respond_with Template.find(params[:id])
  end
end
