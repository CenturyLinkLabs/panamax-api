module DeploymentTarget::Metadata
  extend ActiveSupport::Concern

  included do
    has_one :metadata, class_name: "DeploymentTargetMetadata", dependent: :destroy
  end

  def refresh_metadata
    resource = new_agent_service(AgentMetadataService).find
    create_metadata!(
      agent_version: resource.agent["version"],
      adapter_version: resource.adapter["version"],
      adapter_type: resource.adapter["type"],
      adapter_is_healthy: resource.adapter["isHealthy"]
    )
  end
end
