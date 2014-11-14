class AddHealthToDeploymentTargetsMetadata < ActiveRecord::Migration
  def change
    add_column :deployment_target_metadata, :adapter_is_healthy, :boolean
  end
end
