require 'spec_helper'

describe Service do
  it { should belong_to(:app) }

  it_behaves_like "a docker runnable model"

  describe '#unit_name' do
    it 'postfixes the name with .service' do
      subject.name = 'wordpress'
      expect(subject.unit_name).to eq 'wordpress.service'
    end
  end
end
