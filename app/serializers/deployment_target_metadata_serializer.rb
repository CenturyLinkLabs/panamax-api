class DeploymentTargetMetadataSerializer < ActiveModel::Serializer
  attributes :id, :agent_version, :adapter_version, :adapter_type, :created_at
end
