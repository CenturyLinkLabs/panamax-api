class RemoteMetadataRefreshesController < ApplicationController
  respond_to :html, :json

  def create
    deployment_target = DeploymentTarget.find(params[:deployment_target_id])
    respond_with(
      deployment_target.refresh_metadata,
      location: deployment_targets_path
    )
  end
end
