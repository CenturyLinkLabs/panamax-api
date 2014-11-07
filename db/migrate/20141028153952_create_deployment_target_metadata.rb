class CreateDeploymentTargetMetadata < ActiveRecord::Migration
  def change
    create_table :deployment_target_metadata do |t|
      t.references :deployment_target
      t.string :agent_version
      t.string :adapter_version
      t.string :adapter_type

      t.timestamps
    end
  end
end
