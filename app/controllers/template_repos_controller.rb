class TemplateReposController < ApplicationController

  def index
    headers['Total-Count'] = TemplateRepo.count
    respond_with TemplateRepo.limit(params[:limit].presence)
  end

  def create
    respond_with TemplateRepo.create(template_repo_params), location: nil
  end

  def destroy
    respond_with TemplateRepo.destroy(params[:id])
  end

  def reload
    repo = TemplateRepo.find(params[:id])
    repo.reload_templates
    head status: :ok
  end

  private

  def template_repo_params
    params.permit(:name)
  end
end
