require 'spec_helper'

describe Registry do
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:endpoint_url) }

  describe '.search' do

    let(:query) { 'foo' }

    let(:search_result) do
      {
        'name' => 'foo/bar',
        'description' => 'some description',
        'is_official' => false,
        'is_trusted' => true,
        'star_count' => 2
      }
    end

    let(:dummy_results) { 3.times.map { |i| search_result }}

    let(:registry_client) do
      double(:fake_registry_client, search: {
        'results' => dummy_results
      })
    end

    before do
      PanamaxAgent::Registry::Client.stub(:new).and_return(registry_client)
    end

    it 'passes the search term to the Docker API' do
      expect(registry_client).to receive(:search).with(query)
      described_class.search(query)
    end

    it 'returns a RemoteImage for each search result' do
      result = described_class.search(query)

      expect(result.map(&:class)).to eq 3.times.map { RemoteImage }
    end

    it 'returns RemoteImage instances populated with search result data' do
      result = described_class.search(query).first

      expect(result).to be_kind_of(RemoteImage)
      expect(result.id).to eq search_result['name']
      expect(result.description).to eq search_result['description']
      expect(result.is_official).to eq search_result['is_official']
      expect(result.is_trusted).to eq search_result['is_trusted']
      expect(result.star_count).to eq search_result['star_count']
    end

    context 'when a limit is provided' do

      let(:limit) { 1 }

      it 'returns only the specified number of results' do
        result = described_class.search(query, limit)
        expect(result.size).to eq limit
      end
    end
  end
end
