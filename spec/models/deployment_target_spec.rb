require 'spec_helper'

describe DeploymentTarget do

  describe 'validations' do
    it { should validate_presence_of :name }
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

  describe "#new_agent_service" do
    fixtures :deployment_targets
    let(:target) { deployment_targets(:target1) }
    let(:service_class) { double(new: service_instance) }
    let(:service_instance) { double }
    subject(:new_agent_service) { target.new_agent_service(service_class) }
    before { new_agent_service }

    it "instantiates the passed-in class with the expected arguments" do
      expect(service_class).to have_received(:new).with(
        endpoint_url: target.endpoint_url,
        ca_cert: target.public_cert,
        user: target.username,
        password: target.password
      )
    end

    it { should eq(service_instance) }
  end
end
