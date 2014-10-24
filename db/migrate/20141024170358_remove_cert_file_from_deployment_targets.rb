class RemoveCertFileFromDeploymentTargets < ActiveRecord::Migration
  def change
    remove_column :deployment_targets, :cert_file, :text
  end
end
