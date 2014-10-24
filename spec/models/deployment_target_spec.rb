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

  describe '#cert_file' do
    let(:cert_contents) { 'abc123' }
    let(:deployment_target) { described_class.new(auth_blob: Base64.encode64("a|b|c|#{cert_contents}")) }

    subject { deployment_target.cert_file }

    it 'returns a file with the cert contents' do
      expect(subject.read).to eq cert_contents
    end
  end

  describe '#public_cert' do
    it 'gets the public cert from the instance' do
      subject.auth_blob = Base64.encode64('a|b|c|certificate of authenticity')
      expect(subject.public_cert).to eq 'certificate of authenticity'
    end

    it 'reads the public cert from the file when it is not present on the instance' do
      subject.auth_blob = Base64.encode64('a|b|c|')
      File.stub(:read_if_exists).and_return('certificate contents')
      expect(subject.public_cert).to eq 'certificate contents'
    end

    it 'returns nil if neither the instance or the file contain the cert' do
      expect(subject.public_cert).to eq nil
    end
  end

  describe '#remote_deplyment_model' do
    let (:remote_deployment_model) { subject.send(:remote_deployment_model) }

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
      subject.stub_chain(:cert_file, :path).and_return('certs/foo.crt')

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
