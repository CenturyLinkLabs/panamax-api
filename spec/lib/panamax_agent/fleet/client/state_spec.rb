require 'spec_helper'

describe PanamaxAgent::Fleet::Client::State do

  subject { PanamaxAgent::Fleet::Client.new }

  let(:response) { double(:response) }

  describe '#list_states' do

    before do
      subject.stub(get: response)
    end

    it 'GETs the Fleet state key' do
      opts = { consistent: true, recursive: true, sorted: false }
      expect(subject).to receive(:get)
        .with('v2/keys/_coreos.com/fleet/state', opts)
        .and_return(response)

      subject.list_states
    end

    it 'returns the state response' do
      expect(subject.list_states).to eql(response)
    end
  end

  describe '#get_state' do

    let(:service_name) { 'foo.service' }

    before do
      subject.stub(get: response)
    end

    it 'GETs the named Fleet state key' do
      opts = { consistent: true, recursive: true, sorted: false }
      expect(subject).to receive(:get)
        .with("v2/keys/_coreos.com/fleet/state/#{service_name}", opts)
        .and_return(response)

      subject.get_state(service_name)
    end

    it 'returns the state response' do
      expect(subject.get_state(service_name)).to eql(response)
    end
  end
end
