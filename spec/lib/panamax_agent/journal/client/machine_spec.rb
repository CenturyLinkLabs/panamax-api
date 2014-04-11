require 'spec_helper'

describe PanamaxAgent::Journal::Client::Machine do

  subject { PanamaxAgent::Journal::Client.new }

  let(:response) { double(:response) }

  before do
    subject.stub(get: response)
  end

  describe '#get_machine' do

    it 'GETs the information for the machine resource' do
      expect(subject).to receive(:get)
                         .with("machine")
                         .and_return(response)

      subject.get_machine
    end

    it 'returns the machine response' do
      expect(subject.get_machine).to eql(response)
    end
  end

end
