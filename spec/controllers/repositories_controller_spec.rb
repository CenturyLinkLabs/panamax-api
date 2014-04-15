require 'spec_helper'

describe RepositoriesController do

  describe 'GET list_tags' do

    let(:repository) { 'name/repo' }

    let(:tags) { [{ layer: 'abc123', name: 'foo' }] }

    let(:client) { double(:client, list_repository_tags: tags) }

    before do
      PanamaxAgent.stub(registry_client: client)
    end

    it 'passes the query to the registry client' do
      expect(client).to receive(:list_repository_tags).with(repository)
      get :list_tags, repository: repository, format: :json
    end

    it 'returns the tag list' do
      get :list_tags, repository: repository, format: :json
      expect(response.body).to eql(tags.to_json)
    end
  end
end
