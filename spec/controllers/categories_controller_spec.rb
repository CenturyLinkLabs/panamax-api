require 'spec_helper'

describe CategoriesController do

  let(:app) { apps(:app1) }

  describe '#index' do

    it 'returns the apps categories' do
      get :index, { app_id: app, format: :json }
      expect(response.body).to eq [app_categories(:category1)].to_json
    end
  end

  describe '#create' do

    let(:params) { { name: 'cat1', position: 10 } }

    it 'adds a new category' do
      expect {
        post :create, { app_id: app, format: :json }
      }.to change(AppCategory, :count).by(1)
    end

    it 'initializes the new category with the specified params' do
      post :create, params.merge({ app_id: app, format: :json })

      expect(AppCategory.last.name).to eq params[:name]
      expect(AppCategory.last.position).to eq params[:position]
    end

    it 'returns the category' do
      post :create, params.merge({ app_id: app, format: :json })
      expect(response.body).to eq AppCategory.last.to_json
    end

    it 'returns a 201 status code' do
      post :create, params.merge({ app_id: app, format: :json })
      expect(response.status).to eq 201
    end
  end

  describe '#update' do

    let(:category) { app_categories(:category1) }

    let(:params) { { name: 'cat2', position: 11 } }

    it 'changes the category attributes' do
      put :update, params.merge({ app_id: app, id: category, format: :json })

      category.reload
      expect(category.name).to eql params[:name]
      expect(category.position).to eql params[:position]
    end

    it 'returns a 204 status code' do
      put :update, params.merge({ app_id: app, id: category, format: :json })
      expect(response.status).to eq 204
    end
  end

  describe '#destroy' do

    let(:category) { app_categories(:category1) }

    it 'deletes the specified category' do
      expect {
        delete :destroy, { app_id: app, id: category, format: :json }
      }.to change(AppCategory, :count).by(-1)
    end

    it 'returns a 204 status code' do
      delete :destroy, { app_id: app, id: category, format: :json }
      expect(response.status).to eq 204
    end
  end
end
