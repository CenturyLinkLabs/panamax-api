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
    override = TemplateBuilder.create(params[:override])

    deployment = deployment_target.create_deployment(template, override)

    respond_with deployment, location: nil
  end

  def destroy
    respond_with deployment_target.delete_deployment(params[:id])
  end

  private

  def deployment_target
    DeploymentTarget.find(params[:deployment_target_id])
  end
end
