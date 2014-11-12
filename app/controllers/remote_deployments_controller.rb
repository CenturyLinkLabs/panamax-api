class RemoteDeploymentsController < ApplicationController

  respond_to :json

  def index
    respond_with deployment_service.all
  end

  def show
    respond_with deployment_service.find(params[:id])
  end

  def create
    override = TemplateBuilder.create(params[:override])

    deployment = deployment_service.create(template: template, override: override)

    respond_with deployment, location: nil
  end

  def destroy
    respond_with deployment_service.destroy(params[:id])
  end

  private

  def deployment_service
    @service ||= deployment_target.new_agent_service(DeploymentService)
  end

  def deployment_target
    @deployment_target ||= DeploymentTarget.find(params[:deployment_target_id])
  end

  def template
    resource_id = params[:resource_id]
    if params[:resource_type] == 'App'
      TemplateBuilder.create({ app_id: resource_id }, false)
    else
      Template.find(resource_id)
    end
  end
end
