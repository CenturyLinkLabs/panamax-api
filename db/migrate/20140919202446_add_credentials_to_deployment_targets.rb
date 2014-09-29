class AddCredentialsToDeploymentTargets < ActiveRecord::Migration
  def change
    add_column :deployment_targets, :name, :string
    add_column :deployment_targets, :cert_file, :text
    add_column :deployment_targets, :auth_blob, :text
    remove_column :deployment_targets, :endpoint_url, :string
  end
end
