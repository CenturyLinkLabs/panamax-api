require 'spec_helper'

describe TemplateReposController do

  describe '#index' do

    it 'returns the template repos' do
      get :index, format: :json

      expected = ActiveModel::ArraySerializer.new(
        TemplateRepo.all,
        each_serializer: TemplateRepoSerializer).to_json
      expect(response.body).to eq expected
    end

    it 'returns a 200 status code' do
      get :index, format: :json
      expect(response.status).to eq 200
    end
  end

  describe '#create' do

    let(:params) { { name: 'owner/repo' } }

    it 'adds a new template repo' do
      expect do
        post :create, params.merge(format: :json)
      end.to change(TemplateRepo, :count).by(1)
    end

    it 'initializes the new template repo with the specified params' do
      post :create, params.merge(format: :json)
      expect(TemplateRepo.last.name).to eq params[:name]
    end

    it 'returns the category' do
      post :create, params.merge(format: :json)
      expected = TemplateRepoSerializer.new(TemplateRepo.last).to_json
      expect(response.body).to eq expected
    end

    it 'returns a 201 status code' do
      post :create, params.merge(format: :json)
      expect(response.status).to eq 201
    end
  end

  describe '#destroy' do

    it 'removes the repo' do
      expect do
        delete :destroy, id: template_repos(:repo1).id, format: :json
      end.to change(TemplateRepo, :count).by(-1)
    end

    it 'returns a 204 status code' do
      delete :destroy, id: template_repos(:repo1).id, format: :json
      expect(response.status).to eq 204
    end

  end

  describe '#reload' do
    it 'removes all templates associated with the repo'
    it 'loads templates from the repo'
  end
end
