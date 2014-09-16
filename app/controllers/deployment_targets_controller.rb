class DeploymentTargetsController < ApplicationController

  respond_to :json

  def index
    respond_with DeploymentTarget.all
  end

  def show
    respond_with DeploymentTarget.find(params[:id])
  end

  def create
    respond_with DeploymentTarget.create(deploy_target_params)
  end

  def update
    deploy_target = DeploymentTarget.find(params[:id])
    deploy_target.update(deploy_target_params)
    respond_with deploy_target
  end

  def destroy
    respond_with DeploymentTarget.destroy(params[:id])
  end

  private

  def deploy_target_params
    params.permit(:endpoint_url)
  end
end
