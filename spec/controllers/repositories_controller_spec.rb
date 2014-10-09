require 'spec_helper'

describe RepositoriesController do

  describe 'GET list_tags' do

    let(:repository) { 'name/repo' }

    let(:tags) { %w(tag1 tag2) }

    let(:registry) { Registry.new }

    context 'for a local image' do

      let(:image) { LocalImage.new(id: repository, tags: tags) }

      before do
        LocalImage.stub(:find_by_name).and_return(image)
      end

      it 'finds the local image' do
        expect(LocalImage).to receive(:find_by_name).with(repository)
        get :show, id: repository, local: 'true', format: :json
      end

      it 'returns the array of tag names' do
        get :show, id: repository, local: 'true', format: :json
        expect(response.body).to eq RepositorySerializer.new(image).to_json
      end
    end

    context 'for a remote image' do

      let(:image) { RemoteImage.new(id: repository, tags: tags) }

      context 'when the registry is found by the supplied id' do
        before do
          Registry.stub(:find_by_id).and_return(registry)
          registry.stub(:find_image_by_name).and_return(image)
        end

        it 'looks up the registry' do
          expect(Registry).to receive(:find_by_id).with(7)
          get :show, id: repository, registry_id: 7, format: :json
        end

        it 'finds the remote image' do
          expect(registry).to receive(:find_image_by_name).with(repository)
          get :show, id: repository, format: :json
        end

        it 'returns the array of tag names' do
          get :show, id: repository, format: :json
          expect(response.body).to eq RepositorySerializer.new(image).to_json
        end
      end

      context 'when the registry cannot be located by id' do
        before do
          Registry.stub(:find_by_id).and_return(nil)
          registry.stub(:find_image_by_name).and_return(image)
        end

        it 'returns the first registry in the DB, which should be the docker index, since we seed that' do
          expect(Registry).to receive(:docker_hub)
          get :show, id: repository, format: :json
        end
      end

    end

    context 'when a PanamaxAgent::ConnectionError is raised' do

      before do
        Registry.stub(:find_by_id).and_return(registry)
        registry.stub(:find_image_by_name)
          .and_raise(PanamaxAgent::ConnectionError, 'oops')
      end

      it 'returns the registry connection error message' do
        get :show, id: repository, format: :json

        expect(response.status).to eq 500
        expect(response.body).to eq(
          { message: I18n.t(:registry_connection_error) }.to_json)
      end
    end
  end
end
