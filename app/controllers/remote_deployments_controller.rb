class RemoteDeploymentsController < ApplicationController

  respond_to :json

  def index
    respond_with deployment_target.list_deployments
  end

  def show
    respond_with deployment_target.get_deployment(params[:id])
  end

  def create
    template = Template.find(params[:template_id])
    template_yaml = TemplateFileSerializer.new(template).to_yaml
    respond_with deployment_target.create_deployment(template_yaml), location: nil
  end

  def destroy
    respond_with deployment_target.delete_deployment(params[:id])
  end

  private

  def deployment_target
    DeploymentTarget.find(params[:deployment_target_id])
  end
end
