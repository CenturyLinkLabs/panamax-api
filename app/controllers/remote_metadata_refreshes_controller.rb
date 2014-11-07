class RemoteMetadataRefreshesController < ApplicationController
  respond_to :json

  def create
    deployment_target = DeploymentTarget.find(params[:deployment_target_id])
    metadata = deployment_target.refresh_metadata
    serialized_metadata = DeploymentTargetMetadataSerializer.new(metadata)

    respond_with(
      { metadata: serialized_metadata },
      location: deployment_targets_path
    )
  end
end
