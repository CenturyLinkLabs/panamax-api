require 'spec_helper'

describe PanamaxAgent::Registry::Client do

  describe 'default options' do
    it 'defaults the read_timeout to 15' do
      expect(subject.read_timeout).to eq 15
    end
  end
end
