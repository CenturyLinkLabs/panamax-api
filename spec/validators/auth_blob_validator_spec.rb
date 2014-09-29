require 'spec_helper'

describe AuthBlobValidator do

  let(:record) { DeploymentTarget.new }
  let(:attribute) { 'auth_blob' }

  subject { described_class.new(attributes: [attribute]) }

  context 'when the auth_blob contains 4 parts' do
    let(:value) { Base64.encode64('a|b|c|certificate contents') }

    it 'is valid' do
      subject.validate_each(record, attribute, value)
      expect(record.errors).to be_empty
    end
  end

  context 'when the auth_blob is not base64 encoded' do
    let(:value) { 'a|b|c|certificate contents' }

    it 'is not valid' do
      subject.validate_each(record, attribute, value)
      expect(record.errors[attribute]).to eq ['Invalid Token']
    end
  end

  context 'when the auth_blob is not pipe seperated' do
    let(:value) { Base64.encode64('a,b,c,certificate contents') }

    it 'is not valid' do
      subject.validate_each(record, attribute, value)
      expect(record.errors[attribute]).to eq ['Invalid Token']
    end
  end

  context 'when the auth_blob does not contain 4 parts' do
    let(:value) { Base64.encode64('a|b|c|') }

    it 'is not valid' do
      subject.validate_each(record, attribute, value)
      expect(record.errors[attribute]).to eq ['Invalid Token']
    end
  end
end
