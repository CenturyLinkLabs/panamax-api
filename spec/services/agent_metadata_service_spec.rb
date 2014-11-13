require 'spec_helper'

describe AgentMetadataService do
  describe "#find" do
    let(:endpoint_url) { 'http://endpoint.com' }
    let(:user) { 'foo_user' }
    let(:password) { 'bar_password' }
    let(:ca_cert) { 'cacertificate' }

    let(:base_path) do
      "#{user}:#{password}@#{URI.parse(endpoint_url).host}"
    end

    let(:service) do
      described_class.new(
        endpoint_url: endpoint_url,
        user: user,
        password: password,
        ca_cert: ca_cert)
    end

    subject(:find) { service.find }

    context "when the endpoint responds with metadata JSON" do
      before do
        response = {
          "agent" => { "test" => "agent data" },
          "adapter" => { "test" => "adapter data" }
        }
        stub_request(:get, "#{base_path}/metadata").
          to_return(body: response.to_json, status: 200)
      end

      its(:agent) { should eq({ "test" => "agent data" }) }
      its(:adapter) { should eq({ "test" => "adapter data" }) }
    end

    context "when the endpoint reponds with a 404" do
      before do
        stub_request(:get, "#{base_path}/metadata").
          to_return(body: nil, status: 404)
      end

      it "raise a somewhat helpful exception" do
        expect { find }.to raise_error("metadata not found")
      end
    end
  end
end
