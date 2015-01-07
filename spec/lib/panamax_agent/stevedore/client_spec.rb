require 'spec_helper'

describe PanamaxAgent::Stevedore::Client do

  describe 'default options' do
    it 'defaults the read_timeout to 30' do
      expect(subject.read_timeout).to eq 30
    end
  end
end
