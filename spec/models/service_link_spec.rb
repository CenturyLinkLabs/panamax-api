require 'spec_helper'

describe ServiceLink do
  it { should belong_to(:linked_to_service) }

  describe '#link_string' do
    let(:linked_to_service) { Service.new(name: 'mysql') }

    before do
      subject.alias = 'DB'
      subject.linked_to_service = linked_to_service
    end

    it 'returns the docker link string fragment' do
      expect(subject.link_string).to eql 'mysql:DB'
    end
  end
end
