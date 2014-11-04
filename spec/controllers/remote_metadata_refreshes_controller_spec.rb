require 'spec_helper'

describe RemoteMetadataRefreshesController do
  describe "#create" do
    let(:deployment_target) { deployment_targets(:target1) }
    let(:format) { :json }
    subject(:create) do
      post :create, deployment_target_id: deployment_target.id, format: format
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
        before { create }
        subject { response }

        context "with the HTML format" do
          let(:format) { :html }
          it { should redirect_to(deployment_targets_path) }
        end

        context "with a JSON format" do
          let(:hash) { JSON.parse(response.body) }

          it "returns a JSON representation of the created DeploymentTargetMetadata" do
            metadata = DeploymentTargetMetadata.last
            expect(hash['metadata']['id']).to eq(metadata.id)
          end

          its(:status) { should eq(201) }
        end
      end

      it "persists a single DeploymentTargetMetadata" do
        expect { create }.to change { DeploymentTargetMetadata.count }.by(1)
        expect(DeploymentTargetMetadata.last.agent_version).to eq("1")
      end
    end
  end
end
