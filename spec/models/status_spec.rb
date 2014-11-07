require 'spec_helper'

describe Status do

  it_behaves_like 'an api model'

  describe 'attributes' do
    it { should respond_to :overall }
    it { should respond_to :services }
  end

  describe '#initialize' do

    let(:attrs) { { overall: 'running', services: [] } }

    subject { described_class.new(attrs) }

    it 'initializes the object with the passed-in attrs' do
      expect(subject.overall).to eq attrs[:overall]
      expect(subject.services).to eq attrs[:services]
    end
  end

end
