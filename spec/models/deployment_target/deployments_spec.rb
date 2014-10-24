require 'spec_helper'

describe DeploymentTarget do
  describe '#with_remote_deployment_model' do
    let(:certificate_contents) { 'certificate of authenticity' }

    before do
      subject.auth_blob = Base64.encode64("a|b|c|#{certificate_contents}")
    end

    it 'writes the file before calling the block' do
      subject.should_receive(:remote_deployment_model).with do |cert_file|
        expect(cert_file.read).to eq certificate_contents
      end
      subject.send(:with_remote_deployment_model) { |model| model }
    end
  end

  describe '#remote_deployment_model' do
    let(:fake_temp_file) { double(:fake_temp_file, path: 'certs/foo.crt') }
    let(:remote_deployment_model) { subject.send(:remote_deployment_model, fake_temp_file) }

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
    let(:remote_deployments) do
      [
        RemoteDeployment.new,
        RemoteDeployment.new
      ]
    end

    before do
      RemoteDeployment.stub(:all).and_return(remote_deployments)
    end

    it 'lists the remote deployments' do
      expect(subject.list_deployments).to eq remote_deployments
    end
  end

  describe '#get_deployment' do
    let(:remote_deployment) { RemoteDeployment.new }

    before do
      RemoteDeployment.stub(:find).with(32).and_return(remote_deployment)
    end

    it 'retrieves the specified deployment' do
      expect(subject.get_deployment(32)).to eq remote_deployment
    end
  end

  describe '#create_deployment' do
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
