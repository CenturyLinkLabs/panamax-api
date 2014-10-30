require 'spec_helper'

describe DeploymentTargetMetadataSerializer do
  let(:metadata) { DeploymentTargetMetadata.new }
  let(:serializer) { DeploymentTargetMetadataSerializer.new(metadata) }
  subject { serializer.as_json }

  its(:keys) do
    should match_array([ :id, :agent_version, :adapter_version, :adapter_type, :created_at ])
  end
end
