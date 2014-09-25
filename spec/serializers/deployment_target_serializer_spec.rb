require 'spec_helper'

describe DeploymentTargetSerializer do
  let(:deployment_target_model) { DeploymentTarget.new }

  it 'exposes the attributes to be jsonified' do
    serialized = described_class.new(deployment_target_model).as_json
    expected_keys = [
      :id,
      :name,
      :endpoint_url,
      :auth_blob
    ]
    expect(serialized.keys).to match_array expected_keys
  end
end
