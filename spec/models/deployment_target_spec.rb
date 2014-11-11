require 'spec_helper'

describe DeploymentTarget do

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
end
