require 'spec_helper'

describe RemoteImage do

  describe 'attributes' do
    it { should respond_to :id }
    it { should respond_to :tags }
    it { should respond_to :description }
    it { should respond_to :is_official }
    it { should respond_to :is_trusted }
    it { should respond_to :star_count }
  end

  describe '.search' do

    let(:query) { 'foo' }

    let(:search_result) do
      double(:result,
        id: 'foo/bar',
        info: {
          'description' => 'some description',
          'is_official' => false,
          'is_trusted' => true,
          'star_count' => 2
        }
      )
    end

    before do
      Docker::Image.stub(:search).and_return([
        search_result,
        search_result,
        search_result])
    end

    it 'passes the search term to the Docker API' do
      expect(Docker::Image).to receive(:search).with(term: query)
      described_class.search(query)
    end

    it 'returns a RemoteImage for each search result' do
      result = described_class.search(query)

      expect(result).to be_kind_of(Array)
      expect(result.size).to eq 3
    end

    it 'returns RemoteImage instances populated with search result data' do
      result = described_class.search(query).first

      expect(result).to be_kind_of(RemoteImage)
      expect(result.id).to eq search_result.id
      expect(result.description).to eq search_result.info['description']
      expect(result.is_official).to eq search_result.info['is_official']
      expect(result.is_trusted).to eq search_result.info['is_trusted']
      expect(result.star_count).to eq search_result.info['star_count']
    end

    context 'when a limit is provided' do

      let(:limit) { 1 }

      it 'returns only the specified number of results' do
        result = described_class.search(query, limit)
        expect(result.size).to eq limit
      end
    end
  end

  describe '.find_by_name' do

    let(:name) { 'foo/bar' }
    let(:registry_client) { double(:registry_client) }
    let(:tag_list) do
      [
        { 'name' => 'tag1' },
        { 'name' => 'tag2' },
        { 'name' => 'tag3' },
      ]
    end

    before do
      PanamaxAgent.stub(:registry_client).and_return(registry_client)
      registry_client.stub(:list_repository_tags).and_return(tag_list)
    end

    it 'passes the name to the registry client' do
      expect(registry_client).to receive(:list_repository_tags).with(name)
      described_class.find_by_name(name)
    end

    it 'returns a RemoteImage' do
      result = described_class.find_by_name(name)

      expect(result).to be_kind_of(RemoteImage)
      expect(result.id).to eq name
      expect(result.tags).to eq tag_list.map { |tag| tag['name'] }
    end
  end
end
