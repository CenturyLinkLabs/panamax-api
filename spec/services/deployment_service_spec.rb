require 'spec_helper'

describe DeploymentService do

  let(:endpoint_url) { 'http://endpoint.com' }
  let(:user) { 'foo_user' }
  let(:password) { 'bar_password' }
  let(:ca_cert) { 'cacertificate' }

  let(:base_path) do
    "#{user}:#{password}@#{URI.parse(endpoint_url).host}"
  end

  subject do
    described_class.new(
      endpoint_url: endpoint_url,
      user: user,
      password: password,
      ca_cert: ca_cert)
  end

  describe '#all' do

    let(:deployment_id) { 123 }
    let(:response) { [{ id: deployment_id }].to_json }

    before do
      stub_request(:get, "#{base_path}/deployments")
        .to_return(body: response, status: 200)
    end

    it 'retrieves all remote deployments' do
      result = subject.all

      expect(result.count).to eq 1
      expect(result.first).to be_kind_of(RemoteDeployment)
      expect(result.first.id).to eq deployment_id
    end
  end

  describe '#find' do

    let(:deployment_id) { 123 }
    let(:response) { { id: deployment_id }.to_json }

    context 'when the deployment is found' do

      before do
        stub_request(:get, "#{base_path}/deployments/#{deployment_id}")
          .to_return(body: response, status: 200)
      end

      it 'retrieves the specified remote deployment' do
        result = subject.find(deployment_id)

        expect(result).to be_kind_of(RemoteDeployment)
        expect(result.id).to eq deployment_id
      end
    end

    context 'when the deployment is not found' do

      before do
        stub_request(:get, "#{base_path}/deployments/#{deployment_id}")
          .to_return(status: 404)
      end

      it 'returns nil' do
        expect{ subject.find(deployment_id) }.to raise_error('deployment not found')
      end
    end
  end

  describe '#create' do

    let(:template) { Template.new(name: 'foo') }
    let(:override) { Template.new(name: 'bar') }
    let(:deployment_id) { 123 }
    let(:response) { { id: deployment_id }.to_json }

    before do
      stub_request(:post, "#{base_path}/deployments")
        .with(body: { template: TemplateFileSerializer.new(template), override: TemplateFileSerializer.new(override) }.to_json)
        .to_return(body: response, status: 201)
    end

    it 'creates the remote deployment' do
      result = subject.create(template: template, override: override)
      expect(result).to be_kind_of(RemoteDeployment)
      expect(result.id).to eq deployment_id
    end
  end

  describe '#destroy' do
    let(:deployment_id) { 123 }

    before do
      stub_request(:delete, "#{base_path}/deployments/#{deployment_id}")
        .to_return(status: 204)
    end

    it 'deletes the remote deployment' do
      subject.destroy(deployment_id)
    end
  end
end
