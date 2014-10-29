class DeploymentTargetMetadata < ActiveRecord::Base
  belongs_to :deployment_target

  validates :agent_version, :adapter_version, :adapter_type, presence: true
end
