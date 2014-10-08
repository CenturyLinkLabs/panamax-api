require 'spec_helper'

describe RemoteImage do

  it_behaves_like 'an api model'

  describe 'attributes' do
    it { should respond_to :id }
    it { should respond_to :tags }
    it { should respond_to :description }
    it { should respond_to :is_official }
    it { should respond_to :is_trusted }
    it { should respond_to :star_count }
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
