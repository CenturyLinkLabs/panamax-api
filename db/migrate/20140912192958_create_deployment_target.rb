class CreateDeploymentTarget < ActiveRecord::Migration
  def change
    create_table :deployment_targets do |t|
      t.string :endpoint_url
    end
  end
end
