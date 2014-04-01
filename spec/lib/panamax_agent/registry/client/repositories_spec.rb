require 'spec_helper'

describe PanamaxAgent::Registry::Client::Repositories do

  subject { PanamaxAgent::Registry::Client.new }

  let(:repository) { 'foo/bar' }
  let(:response) { double(:response) }

  before do
    subject.stub(get: response)
  end

  describe '#list_repository_tags' do

    it 'GETs the tags for the repository resource' do
      expect(subject).to receive(:get)
        .with("repositories/#{repository}/tags")
        .and_return(response)

      subject.list_repository_tags(repository)
    end

    it 'returns the tag response' do
      expect(subject.list_repository_tags(repository)).to eql(response)
    end
  end

  describe '#get_repository_tag' do

    it 'GETs the named tag for the repository resource' do
      expect(subject).to receive(:get)
        .with("repositories/#{repository}/tags/#{:tag}")
        .and_return(response)

      subject.get_repository_tag(repository, :tag)
    end

    it 'returns the tag response' do
      expect(subject.get_repository_tag(repository, :tag)).to eql(response)
    end
  end
end
