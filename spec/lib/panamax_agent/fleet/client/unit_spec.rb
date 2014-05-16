require 'spec_helper'

describe PanamaxAgent::Fleet::Client::Unit do

  subject { PanamaxAgent::Fleet::Client.new }

  let(:response) { double(:response) }

  describe '#create_unit' do

    let(:sha) { '33ef9ba9029c' }
    let(:unit_def) { { exec_start: '/bin/bash' } }

    before do
      subject.stub(put: response)
    end

    it 'PUTs the unit def to the Fleet unit key' do
      opts = {
        querystring: { 'prevExist' => false },
        body: { value: unit_def.to_json }
      }

      expect(subject).to receive(:put)
        .with("v2/keys/_coreos.com/fleet/unit/#{sha}", opts)
        .and_return(response)

      subject.create_unit(sha, unit_def)
    end

    it 'returns the job response' do
      expect(subject.create_unit(sha, unit_def)).to eql(response)
    end
  end

  describe '#delete_unit' do

    let(:sha) { '33ef9ba9029c' }

    before do
      subject.stub(delete: response)
    end

    it 'DELETEs the named Fleet unit key' do
      opts = { dir: false, recursive: false }
      expect(subject).to receive(:delete)
        .with("v2/keys/_coreos.com/fleet/unit/#{sha}", opts)
        .and_return(response)

      subject.delete_unit(sha)
    end

    it 'returns the job response' do
      expect(subject.delete_unit(sha)).to eql(response)
    end
  end
end
