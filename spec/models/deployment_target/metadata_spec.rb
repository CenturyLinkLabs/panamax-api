require 'spec_helper'

describe DeploymentTarget do
  fixtures :deployment_targets
  let(:deployment_target) { deployment_targets(:target1) }

  describe "#metadata" do
    fixtures :deployment_target_metadata

    let(:metadata) { deployment_target_metadata(:metadata1) }
    subject { deployment_target.metadata }
    before do
      deployment_target.metadata = metadata
      deployment_target.save!
      deployment_target.reload
    end

    it { should eq(metadata) }

    describe "destruction" do
      before { deployment_target.destroy }

      it "does not leave orphaned metadata" do
        expect(DeploymentTargetMetadata.count).to be_zero
      end
    end
  end

  describe '#refresh_metadata' do
    let(:metadata_service) { double(find: metadata) }
    let(:metadata) do
      RemoteAgentMetadata.new(
        agent: { "version" => "1" },
        adapter: { "version" => "2", "type" => "Test Type", "isHealthy" => true }
      )
    end
    before do
      allow(deployment_target).to(
        receive(:new_agent_service).
        with(AgentMetadataService).
        and_return(metadata_service)
      )
    end
    subject(:refresh_metadata) { deployment_target.refresh_metadata }

    it "persists a single DeploymentTargetMetadata" do
      expect { refresh_metadata }.to change { DeploymentTargetMetadata.count }.by(1)
    end

    describe "the persisted metadata" do
      subject { DeploymentTargetMetadata.last }

      context "when metadata does not already exist for the target" do
        before { refresh_metadata }

        its(:agent_version) { should eq("1") }
        its(:adapter_version) { should eq("2") }
        its(:adapter_type) { should eq("Test Type") }
        its(:adapter_is_healthy) { should be_truthy }
      end

      context "when metadata already exists for the target" do
        let(:deployment_target) { deployment_targets(:target_with_metadata) }

        it "overwrites the existing metadata" do
          expect { refresh_metadata }.to_not change { DeploymentTargetMetadata.count }
          expect(deployment_target.metadata.agent_version).to eq("1")
        end
      end
    end
  end
end
