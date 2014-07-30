class TemplateReposController < ApplicationController
  respond_to :json

  def index
    respond_with TemplateRepo.all
  end

  def create
    respond_with TemplateRepo.create(template_repo_params), location: nil
  end

  def destroy
    respond_with TemplateRepo.destroy(params[:id])
  end

  private

  def template_repo_params
    params.permit(:name)
  end
end
