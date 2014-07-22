require 'spec_helper'

describe RepositoriesController do

  describe 'GET list_tags' do

    let(:repository) { 'name/repo' }

    context 'for a local image' do
      let(:image_list) do
        [double(:image, info: { 'RepoTags' => ['joshhartnett/rails:foo'] })]
      end

      before do
        Image.stub(:find_local_for).and_return(image_list)
      end

      it 'returns the array of tag names' do
        get :list_tags, repository: repository, local_image: 'true', format: :json
        expect(response.body).to eql(['foo'].to_json)
      end
    end

    context 'for a remote image' do
      let(:tags) { [{ 'layer' => 'abc123', 'name' => 'foo' }] }

      let(:client) { double(:client, list_repository_tags: tags) }

      before do
        PanamaxAgent.stub(registry_client: client)
      end

      it 'passes the query to the registry client' do
        expect(client).to receive(:list_repository_tags).with(repository)
        get :list_tags, repository: repository, format: :json
      end

      it 'returns the array of tag names' do
        get :list_tags, repository: repository, format: :json
        expect(response.body).to eql(['foo'].to_json)
      end
    end

    context 'when a PanamaxAgent::ConnectionError is raised' do

      before do
        PanamaxAgent.stub(:registry_client)
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
