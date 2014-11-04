require 'spec_helper'

describe DeploymentTarget do

  let(:template) do
    {
      'name' => 'Wordpress Application',
      'description' => 'a blog'
    }
  end

  let(:override) do
    {
      'name' => 'Wordpress Application',
      'description' => 'a glob'
    }
  end

  let(:remote_deployment) { RemoteDeployment.new }

  let(:remote_deployments) do
    [
      RemoteDeployment.new,
      RemoteDeployment.new
    ]
  end

  describe 'validations' do
    it { should validate_presence_of :name }
    it { should validate_uniqueness_of :name }
  end

  describe '#endpoint_url' do
    subject do
      described_class.new(
        auth_blob: Base64.encode64('http://example.com|b|c|d')
      ).endpoint_url
    end

    it { should eq 'http://example.com' }
  end

  describe '#username' do
    subject do
      described_class.new(
        auth_blob: Base64.encode64('a|bob|c|d')
      ).username
    end

    it { should eq 'bob' }
  end

  describe '#password' do
    subject do
      described_class.new(
        auth_blob: Base64.encode64('a|b|pazzword|d')
      ).password
    end

    it { should eq 'pazzword' }
  end

  describe '#public_cert' do
    it 'gets the public cert from the instance' do
      subject.auth_blob = Base64.encode64('a|b|c|certificate of authenticity')
      expect(subject.public_cert).to eq 'certificate of authenticity'
    end
  end

  describe '#with_remote_deployment_model' do
    before do
      fake_tmp_file = double(:fake_tmp_file, write: true, path: 'certs/foo.crt', close: true)
      Tempfile.stub(:new).and_return(fake_tmp_file)
    end

    let (:remote_deployment_model) do
      subject.send(:with_remote_deployment_model) { |model| model }
    end

    it 'sets the proper user' do
      subject.auth_blob = Base64.encode64('a|bob|c|d')
      expect(remote_deployment_model.user).to eq 'bob'
    end

    it 'sets the proper password' do
      subject.auth_blob = Base64.encode64('a|b|abc123|d')
      expect(remote_deployment_model.password).to eq 'abc123'
    end

    it 'sets the proper site_url' do
      subject.auth_blob = Base64.encode64('example.com|b|c|d')
      expect(remote_deployment_model.site.to_s).to eq 'example.com'
    end

    it 'sets the proper element_name' do
      expect(remote_deployment_model.element_name).to eq 'deployment'
    end

    it 'sets the proper ssl options' do
      expect(remote_deployment_model.ssl_options).to eq({
        verify_mode: OpenSSL::SSL::VERIFY_PEER,
        ca_file: 'certs/foo.crt'
      })
    end
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
      expect(RemoteDeployment).to receive(:create) do |opts|
        expect(opts.keys).to match_array([:template, :override])
        expect(opts[:template]).to be_kind_of(TemplateFileSerializer)
        expect(opts[:template].object).to eq template
        expect(opts[:override]).to be_kind_of(TemplateFileSerializer)
        expect(opts[:override].object).to eq override
      end
      subject.create_deployment(template, override)
    end
  end

  describe '#delete_deployment' do
    it 'deletes the supplied deployment' do
      expect(RemoteDeployment).to receive(:delete).with(33)
      subject.delete_deployment(33)
    end
  end
end
