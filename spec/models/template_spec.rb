require 'spec_helper'

describe Template do
  it { should have_and_belong_to_many(:images) }
  it { should validate_presence_of(:name) }

  describe '#categories' do
    it 'returns the categories of its child images' do
      expect(subject.categories).to match_array(subject.images.map(&:categories).flatten.uniq.compact)
    end
  end
end
