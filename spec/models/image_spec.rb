require 'spec_helper'

describe Image do
  it { should belong_to(:template) }
  it { should respond_to :is_official }
  it { should respond_to :is_trusted }
  it { should respond_to :star_count }
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:repository) }
  
  describe '.search_remote_index' do

    let(:query) { { term: 'some_term' } }

    let(:remote_image) do
      double(:remote_image,
        id: 'foo/bar',
        info: { description: 'fizz', is_official: true, is_trusted: true })
    end

    before do
      Docker::Image.stub(:search).and_return([remote_image])
    end

    it 'searches the remote Docker index' do
      expect(Docker::Image).to receive(:search).with(query).and_return([remote_image])
      Image.search_remote_index(query)
    end

    it 'returns a list of Image models' do
      images = Image.search_remote_index(query)

      expect(images).to be_kind_of(Array)
      expect(images).to have(1).items
      expect(images.first.repository).to eql(remote_image.id)
    end
  end

  describe '.all_local' do

    let(:local_image) do
      double(:local_image,
        info: { 'RepoTags' => ['foo/bar'] })
    end

    before do
      Docker::Image.stub(:all).and_return([])
    end

    it 'searches the local Docker index' do
      expect(Docker::Image).to receive(:all).and_return([])
      Image.all_local
    end

    context 'when local cache contains an image' do

      before do
        Docker::Image.stub(:all).and_return([local_image])
      end

      it 'returns the local image' do
        images = Image.all_local

        expect(images).to be_kind_of(Array)
        expect(images).to have(1).items
        expect(images.first.repository).to eql(local_image.info['RepoTags'].first)
      end
    end

    context 'when local cache contains an empty image' do

      let(:none_image) do
        double(:local_image,
          info: { 'RepoTags' => ['<none>:<none>'] })
      end

      before do
        Docker::Image.stub(:all).and_return([none_image])
      end

      it 'returns no results' do
        images = Image.all_local

        expect(images).to be_kind_of(Array)
        expect(images).to have(0).items
      end
    end

    context 'when local cache contains a duplicate images' do

      before do
        Docker::Image.stub(:all).and_return([local_image, local_image])
      end

      it 'returns only unique results' do
        images = Image.all_local

        expect(images).to be_kind_of(Array)
        expect(images).to have(1).items
        expect(images.first.repository).to eql(local_image.info['RepoTags'].first)
      end
    end
  end

  describe '.local_with_repo_like' do
    context 'when there are no local images' do

      before do
        Image.stub(:all_local).and_return([])
      end

      it 'returns an empty array' do
        images = Image.local_with_repo_like('query')
        expect(images).to be_kind_of(Array)
        expect(images).to be_empty
      end
    end

    context 'when there are local images' do
      let(:matching_image) { double(:matching_image, repository: 'query') }

      let(:other_image) { double(:other_image, repository: 'blah') }

      before do
        Image.stub(:all_local).and_return([matching_image, other_image])
      end

      it 'returns only the images with repositories like the query argument' do
        images = Image.local_with_repo_like('query')

        expect(images).to be_kind_of(Array)
        expect(images).to have(1).items
        expect(images.first).to be matching_image
      end
    end
  end

  describe '.find_local_for' do

    let(:image_list) do
      [
        double(:image, info: { 'RepoTags' => ['joshhartnett/rails:foo'] }),
        double(:image, info: { 'RepoTags' => ['timothydalton/ubuntu:foo'] })
      ]
    end

    before do
      Docker::Image.stub(:all).and_return(image_list)
    end

    it 'returns all local images that match the given repo name' do
      result = described_class.find_local_for('joshhartnett/rails')
      expect(result).to match_array([image_list.first])
    end
  end

  describe '#recommended' do
    it 'defaults to false if not set' do
      expect(subject.recommended).to eq false
    end

    it 'is true if set to true' do
      truther = described_class.new(recommended: true)
      expect(truther.recommended).to eq true
    end
  end
end
