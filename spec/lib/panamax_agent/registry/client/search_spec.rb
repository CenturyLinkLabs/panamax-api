require 'spec_helper'

describe PanamaxAgent::Registry::Client::Search do

  subject { PanamaxAgent::Registry::Client.new }

  let(:response) { double(:response) }

  before do
    allow(subject).to receive(:get).and_return(response)
  end

  describe '#search' do
    it 'makes a get request to the search endpoint' do
      expect(subject).to receive(:get)
        .with('v1/search', q: 'mysql')
        .and_return(response)

      subject.search('mysql')
    end

    it 'returns the tag response' do
      expect(subject.search('mysql')).to eql(response)
    end
  end
end
