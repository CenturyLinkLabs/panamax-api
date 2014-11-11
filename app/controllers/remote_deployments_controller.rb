class RemoteDeploymentsController < ApplicationController

  respond_to :json

  def index
    respond_with deployment_service.all
  end

  def show
    respond_with deployment_service.find(params[:id])
  end

  def create
    template = Template.find(params[:template_id])
    override = TemplateBuilder.create(params[:override])

    deployment = deployment_service.create(template: template, override: override)

    respond_with deployment, location: nil
  end

  def destroy
    respond_with deployment_service.destroy(params[:id])
  end

  private

  def deployment_service
    @deployment_service ||= DeploymentService.new(
      endpoint_url: deployment_target.endpoint_url,
      ca_cert: deployment_target.public_cert,
      user: deployment_target.username,
      password: deployment_target.password)
  end

  def deployment_target
    @deployment_target ||= DeploymentTarget.find(params[:deployment_target_id])
  end
end
