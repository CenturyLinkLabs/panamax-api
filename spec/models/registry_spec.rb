require 'spec_helper'

describe Registry do
  let(:registry_client) do
    double(:registry_client)
  end

  before do
    allow(PanamaxAgent::Registry::Client).to receive(:new).and_return(registry_client)
  end

  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:endpoint_url) }

  describe '.docker_hub' do
    fixtures :registries

    it 'returns the special docker hub record' do
      expect(described_class.docker_hub.id).to eq 0
      expect(described_class.docker_hub.name).to eq 'Docker Hub'
      expect(described_class.docker_hub.endpoint_url).to eq 'https://index.docker.io'
    end
  end

  describe ".enabled" do
    fixtures :registries
    subject { Registry.enabled }
    before { registries(:registry0).update_attribute(:enabled, false) }

    it { should eq([ registries(:registry1) ]) }
  end

  describe '.search' do
    let(:successful_registry) { double(:successful_registry) }
    let(:errored_registry) { double(:errored_registry) }
    let(:error_hash) { { summary: "Problem" } }
    let(:first_image) { double }
    let(:second_image) { double }
    let(:query) { 'foo' }
    subject(:search) { described_class.search(query) }

    before do
      allow(Registry).to receive(:enabled).and_return([ successful_registry, errored_registry ])
      allow(successful_registry).to receive(:search).and_return({ remote_images: [ first_image, second_image ] })
      allow(errored_registry).to receive(:search).and_return({ error: error_hash })
      search
    end

    it 'calls search on the registry with the terms' do
      expect(successful_registry).to have_received(:search).with(query)
      expect(errored_registry).to have_received(:search).with(query)
    end

    its(:first) { should eq([ first_image, second_image ]) }
    its(:second) { should eq([ error_hash ]) }

    context 'when a limit is provided' do
      subject(:search) { described_class.search(query, 1) }
      its(:first) { should eq([ first_image ]) }
      its(:second) { should eq([ error_hash ]) }
    end
  end

  describe '#search' do
    fixtures :registries
    let(:registry) { registries(:registry0) }
    subject(:search) { registry.search("test") }

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

    context 'when the RegistryClient raises an error' do
      before { allow(registry_client).to receive(:search).and_raise(StandardError.new("Error details")) }
      subject { search[:error] }

      its([:registry_id]) { should eq(registry.id) }
      its([:summary]) { should eq(I18n.t('registry_search_error', name: registry.name)) }
    end

    context 'when the RegistryClient search is successful' do
      before { allow(registry_client).to receive(:search).and_return({ 'results' => dummy_results }) }

      it 'returns a RemoteImage for each search result' do
        expect(search[:remote_images].map(&:class)).to eq 3.times.map { RemoteImage }
      end

      it 'returns RemoteImage instances populated with search result data' do
        result = search[:remote_images].first

        expect(result).to be_kind_of(RemoteImage)
        expect(result.id).to eq search_result['name']
        expect(result.description).to eq search_result['description']
        expect(result.is_official).to eq search_result['is_official']
        expect(result.is_trusted).to eq search_result['is_trusted']
        expect(result.star_count).to eq search_result['star_count']
        expect(result.registry_id).to eq registry.id
        expect(result.registry_name).to eq registry.name
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
        allow(registry_client).to receive(:list_repository_tags).and_return(tag_list_old_style)
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
        allow(registry_client).to receive(:list_repository_tags).and_return(tag_list_new_style)
      end

      it 'properly maps the tags' do
        result = subject.find_image_by_name(name)

        expect(result.tags).to eq tag_list_new_style.map { |k,v| k }
      end
    end
  end

  describe '#prefix' do
    context 'when the registry is docker hub' do
      fixtures :registries
      let(:docker_hub) { registries(:registry0) }
      subject { docker_hub.prefix }

      it { should be_blank }
    end

    context 'when the registry is not docker hub' do
      let(:registry) { Registry.new(endpoint_url: 'http://example.com:5000') }
      subject { registry.prefix }

      it { should eq 'example.com:5000/' }
    end

    context 'when the registry is https' do
      let(:registry) { Registry.new(endpoint_url: 'https://private.com:5000') }
      subject { registry.prefix }

      it { should eq 'private.com:5000/' }
    end
  end
end
