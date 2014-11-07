require 'spec_helper'

describe RemoteMetadataRefreshesController do
  describe "#create" do
    let(:deployment_target) { deployment_targets(:target1) }
    subject(:create) do
      post :create, deployment_target_id: deployment_target.id, format: :json
    end

    describe "when the agent endpoint responds"  do
      before do
        stub_agent_metadata_request(
          deployment_target,
          metadata: {
            agent: { version: "1" },
            adapter: { version: "2", type: "Test Type" }
          }
        )
      end

      describe "the response" do
        let(:hash) { JSON.parse(response.body) }
        subject { response }
        before { create }

        it "returns a JSON representation of the created DeploymentTargetMetadata" do
          metadata = DeploymentTargetMetadata.last
          expect(hash['metadata']['id']).to eq(metadata.id)
        end

        its(:status) { should eq(201) }
      end

      it "persists a single DeploymentTargetMetadata" do
        expect { create }.to change { DeploymentTargetMetadata.count }.by(1)
        expect(DeploymentTargetMetadata.last.agent_version).to eq("1")
      end
    end
  end
end
