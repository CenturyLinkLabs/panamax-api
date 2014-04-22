require 'spec_helper'

describe PanamaxAgent::Fleet::Client::Payload do

  subject { PanamaxAgent::Fleet::Client.new }

  let(:response) { double(:response) }

  describe '#list_payloads' do

    before do
      subject.stub(get: response)
    end

    it 'GETs the Fleet payload key' do
      opts = { consistent: true, recursive: true, sorted: true }
      expect(subject).to receive(:get)
        .with("v2/keys/_coreos.com/fleet/payload", opts)
        .and_return(response)

      subject.list_payloads
    end

    it 'returns the payload response' do
      expect(subject.list_payloads).to eql(response)
    end
  end

  describe '#get_payload' do

    let(:service_name) { 'foo.service' }

    before do
      subject.stub(get: response)
    end

    it 'GETs the named Fleet payload key' do
      opts = { consistent: true, recursive: true, sorted: false }
      expect(subject).to receive(:get)
        .with("v2/keys/_coreos.com/fleet/payload/#{service_name}", opts)
        .and_return(response)

      subject.get_payload(service_name)
    end

    it 'returns the payload response' do
      expect(subject.get_payload(service_name)).to eql(response)
    end
  end

  describe '#create_payload' do

    let(:service_name) { 'foo.service' }
    let(:service_def) { { name: service_name } }

    before do
      subject.stub(put: response)
    end

    it 'PUTs the service def to the Fleet payload key' do
      opts = {
        querystring: { 'prevExist' => false },
        body: { value: service_def.to_json }
      }

      expect(subject).to receive(:put)
        .with("v2/keys/_coreos.com/fleet/payload/#{service_name}", opts)
        .and_return(response)

      subject.create_payload(service_name, service_def)
    end

    it 'returns the payload response' do
      expect(subject.create_payload(service_name, service_def)).to eql(response)
    end
  end

  describe '#delete_payload' do

    let(:service_name) { 'foo.service' }

    before do
      subject.stub(delete: response)
    end

    it 'DELETEs the named Fleet payload key' do
      opts = { dir: false, recursive: false }
      expect(subject).to receive(:delete)
        .with("v2/keys/_coreos.com/fleet/payload/#{service_name}", opts)
        .and_return(response)

      subject.delete_payload(service_name)
    end

    it 'returns the payload response' do
      expect(subject.delete_payload(service_name)).to eql(response)
    end
  end
end
