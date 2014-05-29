require 'spec_helper'

describe PanamaxAgent do

  describe '.configure' do

    after do
      PanamaxAgent.reset
    end

    it 'allows access to configuration options' do
      PanamaxAgent.configure { |config| config.adapter = :foo }
      expect(PanamaxAgent.adapter).to eql :foo
    end
  end

  describe '.registry_client' do

    it 'returns a Registry::Client instance' do
      expect(PanamaxAgent.registry_client).to be_kind_of(PanamaxAgent::Registry::Client)
    end
  end

  describe '.fleet_client' do

    it 'returns a Fleet::Client instance' do
      expect(PanamaxAgent.fleet_client).to be_kind_of(PanamaxAgent::Fleet::Client)
    end
  end

  describe '.journal_client' do

    before do
      PanamaxAgent.unstub(:journal_client)
    end

    it 'returns a Journal::Client instance' do
      expect(PanamaxAgent.journal_client).to be_kind_of(PanamaxAgent::Journal::Client)
    end
  end

end
