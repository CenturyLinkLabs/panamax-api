class JobTemplatesController < ApplicationController

  respond_to :json

  def index
    type = params[:type] || JobTemplate.default_type
    respond_with JobTemplate.where(type: type)
  end

  def show
    respond_with JobTemplate.find(params[:id])
  end
end
