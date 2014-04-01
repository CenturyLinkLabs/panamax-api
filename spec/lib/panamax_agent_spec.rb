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
end
