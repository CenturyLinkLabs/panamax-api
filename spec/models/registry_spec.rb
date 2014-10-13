require 'spec_helper'

describe Registry do
  let(:registry_client) do
    double(:fake_registry_client)
  end

  before do
    PanamaxAgent::Registry::Client.stub(:new).and_return(registry_client)
  end

  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:endpoint_url) }

  describe '.docker_hub' do
    it 'returns the special docker hub record' do
      expect(described_class.docker_hub.id).to eq 0
      expect(described_class.docker_hub.name).to eq 'Docker Hub'
      expect(described_class.docker_hub.endpoint_url).to eq 'https://index.docker.io'
    end
  end

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

    before do
      registry_client.stub(:search).and_return({
        'results' => dummy_results
      })
    end

    it 'passes the search term to the Docker API' do
      expect(registry_client).to receive(:search).with(query)
      described_class.search(query)
    end

    it 'returns a RemoteImage for each search result' do
      result = described_class.search(query)

      expect(result.map(&:class)).to eq 6.times.map { RemoteImage }
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

    context 'when a registry is not enabled' do
      let(:docker_hub) { registries(:registry0) }

      before do
        docker_hub.update_attribute(:enabled, false)
      end

      it 'searches only the enabled registries' do
        result = described_class.search(query)
        expect(result.map(&:registry_id)).to_not include(docker_hub.id)
      end
    end

    context 'when a limit is provided' do

      let(:limit) { 1 }

      it 'returns only the specified number of results' do
        result = described_class.search(query, limit)
        expect(result.size).to eq limit
      end
    end
  end

  describe '#find_image_by_name' do

    let(:name) { 'foo/bar' }

    context 'with response containing the old style tag list' do
      let(:tag_list_old_style) do
        [
          { 'name' => 'tag1', layer: '123tr' },
          { 'name' => 'tag2', layer: 'abc123' },
          { 'name' => 'tag3', layer: '345try' },
        ]
      end

      before do
        registry_client.stub(:list_repository_tags).and_return(tag_list_old_style)
      end

      it 'passes the name to the registry client' do
        expect(registry_client).to receive(:list_repository_tags).with(name)
        subject.find_image_by_name(name)
      end

      it 'returns a RemoteImage' do
        result = subject.find_image_by_name(name)

        expect(result).to be_kind_of(RemoteImage)
        expect(result.id).to eq name
        expect(result.tags).to eq tag_list_old_style.map { |tag| tag['name'] }
      end
    end

    context 'with response containing the new style tags list' do
      let(:tag_list_new_style) do
        {
          'tag1' => '6b4e8a7373f',
          'tag2' => 'ljaajsdfl',
          'tag3' => 'aldjf34s'
        }
      end

      before do
        registry_client.stub(:list_repository_tags).and_return(tag_list_new_style)
      end

      it 'properly maps the tags' do
        result = subject.find_image_by_name(name)

        expect(result.tags).to eq tag_list_new_style.map { |k,v| k }
      end

    end
  end
end
