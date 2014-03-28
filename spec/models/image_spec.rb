require 'spec_helper'

describe Image do
  it { should have_and_belong_to_many(:templates) }
  it { should respond_to :is_official }
  it { should respond_to :is_trusted }
  it { should respond_to :star_count }

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
      Docker::Image.should_receive(:search).with(query).and_return([remote_image])
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
      double(:remote_image,
        info: { 'RepoTags' => ['foo/bar'] })
    end

    before do
      Docker::Image.stub(:all).and_return([local_image])
    end

    it 'searches the local Docker index' do
      Docker::Image.should_receive(:all).and_return([local_image])
      Image.all_local
    end

    it 'returns a list of Image models' do
      images = Image.all_local

      expect(images).to be_kind_of(Array)
      expect(images).to have(1).items
      expect(images.first.repository).to eql(local_image.info['RepoTags'].first)
    end
  end
end
