require 'spec_helper'

describe RepositoriesController do

  describe 'GET list_tags' do

    let(:repository) { 'name/repo' }

    let(:tags) { %w(tag1 tag2) }
    let(:image) { double(:image, tags: tags) }

    context 'for a local image' do

      before do
        LocalImage.stub(:find_by_name).and_return(image)
      end

      it 'finds the local image' do
        expect(LocalImage).to receive(:find_by_name).with(repository)
        get :list_tags, repository: repository, local_image: 'true', format: :json
      end

      it 'returns the array of tag names' do
        get :list_tags, repository: repository, local_image: 'true', format: :json
        expect(response.body).to eql(tags.to_json)
      end
    end

    context 'for a remote image' do

      before do
        RemoteImage.stub(:find_by_name).and_return(image)
      end

      it 'finds the remote image' do
        expect(RemoteImage).to receive(:find_by_name).with(repository)
        get :list_tags, repository: repository, local_image: true, format: :json
      end

      it 'returns the array of tag names' do
        get :list_tags, repository: repository, local_image: true, format: :json
        expect(response.body).to eql(tags.to_json)
      end

    end

    context 'when a PanamaxAgent::ConnectionError is raised' do

      before do
        RemoteImage.stub(:find_by_name)
          .and_raise(PanamaxAgent::ConnectionError, 'oops')
      end

      it 'returns the registry connection error message' do
        get :list_tags, repository: repository, format: :json

        expect(response.status).to eq 500
        expect(response.body).to eq(
          { message: I18n.t(:registry_connection_error) }.to_json)
      end
    end
  end
end
