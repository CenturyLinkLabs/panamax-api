require 'spec_helper'

describe Template do

  it_behaves_like 'a classifiable model'

  it { should have_many(:images) }
  it { should validate_presence_of(:name) }

  describe '.all_keywords' do
    fixtures :templates
    before do
      templates(:wordpress).update(keywords: 'wordpress, sizzle, two words')
      templates(:another).update(keywords: 'another,SiZzle')
    end

    it 'rolls up all the keywords with counts' do
      expected = [
        { keyword: 'another', count: 1 },
        { keyword: 'sizzle', count: 2 },
        { keyword: 'two words', count: 1 },
        { keyword: 'wordpress', count: 1 }
      ]
      expect(described_class.all_keywords).to match_array expected
    end
  end

  describe '.search' do
    fixtures :templates

    it 'returns templates with name or keyword matching the term' do
      expect(described_class.search('wp')).to match_array([templates(:wordpress), templates(:another)])
    end
    it 'returns templates with keyword matching the term' do
      expect(described_class.search('blah')).to match_array([templates(:another)])
    end
    it 'returns templates with name matching the term' do
      expect(described_class.search('wordpress')).to match_array([templates(:wordpress)])
    end
    it 'matches all terms' do
      expect(described_class.search('asdf, wordpress, blah')).to(
        match_array([templates(:wordpress), templates(:another)])
      )
    end

    context 'when a limit parameter is supplied' do

      let(:limit) { 1 }

      it 'limits the returned results to the specified count' do
        expect(described_class.search('wp', limit)).to have(limit).items
      end
    end
  end

  describe '#categories' do
    it 'returns the categories of its child images' do
      expect(subject.categories).to match_array(subject.images.map(&:categories).flatten.uniq.compact)
    end
  end
end
