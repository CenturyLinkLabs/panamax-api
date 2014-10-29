module DeploymentTarget::Metadata
  extend ActiveSupport::Concern

  included do
    has_one :metadata, class_name: "DeploymentTargetMetadata", dependent: :destroy
  end

  def refresh_metadata
    resource = agent_metadata_service.find
    create_metadata!(
      agent_version: resource.agent["version"],
      adapter_version: resource.adapter["version"],
      adapter_type: resource.adapter["type"]
    )
  end

  private

  def agent_metadata_service
    @agent_metadata_service ||= AgentMetadataService.new(
      endpoint_url: endpoint_url,
      ca_cert: public_cert,
      user: username,
      password: password)
  end
end
