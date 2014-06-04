require 'spec_helper'

describe Template do
  it { should have_and_belong_to_many(:images) }
  it { should validate_presence_of(:name) }

  context 'when rendered to json' do
    it 'includes an image count' do
      expect(subject.to_json).to include("\"image_count\":#{subject.images.count}")
    end
  end

  describe '#categories' do
    it 'returns the categories of its child images' do
      expect(subject.categories).to match_array(subject.images.map(&:categories).flatten.uniq.compact)
    end
  end
end
