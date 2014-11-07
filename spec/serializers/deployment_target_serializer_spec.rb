require 'spec_helper'

describe DeploymentTargetSerializer do
  let(:deployment_target_model) { DeploymentTarget.new }
  subject(:serialized) { described_class.new(deployment_target_model).as_json }

  it 'exposes the attributes to be jsonified' do
    expected_keys = [
      :id,
      :name,
      :endpoint_url,
      :auth_blob,
      :metadata
    ]
    expect(serialized.keys).to match_array expected_keys
    expect(serialized[:metadata]).to be_nil
  end

  describe "metadata" do
    subject { serialized[:metadata] }

    context "with no associated metadata" do
      it { should be_nil }
    end

    context "with associated metadata" do
      let(:deployment_target_model) { deployment_targets(:target_with_metadata) }
      its([:id]) { should eq(deployment_target_metadata(:metadata1).id) }
    end
  end
end
