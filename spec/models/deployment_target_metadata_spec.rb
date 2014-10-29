require 'spec_helper'

describe DeploymentTargetMetadata do
  it { should belong_to(:deployment_target) }

  it { should validate_presence_of(:agent_version) }
  it { should validate_presence_of(:adapter_version) }
  it { should validate_presence_of(:adapter_type) }
end
