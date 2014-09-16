require 'spec_helper'

describe DeploymentTarget do

  let(:template) do
    {
      'name' => 'Wordpress Application',
      'description' => 'a blog'
    }
  end

  let(:remote_deployment) { RemoteDeployment.new }

  let(:remote_deployments) do
    [
      RemoteDeployment.new,
      RemoteDeployment.new
    ]
  end

  describe '#list_deployments' do
    before do
      RemoteDeployment.stub(:all).and_return(remote_deployments)
    end

    it 'lists the remote deployments' do
      expect(subject.list_deployments).to eq remote_deployments
    end
  end

  describe '#get_deployment' do
    before do
      RemoteDeployment.stub(:find).with(32).and_return(remote_deployment)
    end

    it 'retrieves the specified deployment' do
      expect(subject.get_deployment(32)).to eq remote_deployment
    end
  end

  describe '#create_deployment' do
    it 'creates the deployment' do
      expect(RemoteDeployment).to receive(:create).with(template: template)
      subject.create_deployment(template)
    end
  end

  describe '#delete_deployment' do
    it 'deletes the supplied deployment' do
      expect(RemoteDeployment).to receive(:delete).with(33)
      subject.delete_deployment(33)
    end
  end
end
