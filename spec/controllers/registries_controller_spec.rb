require 'spec_helper'

describe RegistriesController do

  let(:registry) { registries(:registry1) }

  describe 'POST #create' do
    let(:create_params) do
      {
        'name' => 'top secret',
        'endpoint_url' => 'http://boom.shaka'
      }
    end

    context 'when creation is successful' do
      it 'creates the registry' do
        expect do
          post :create, create_params.merge(format: :json)
        end.to change { Registry.count }.by(1)
      end

      it 'returns an HTTP 201 status code' do
        post :create, create_params.merge(format: :json)
        expect(response.status).to eq 201
      end
    end
  end

  describe 'PATCH/PUT #update' do
    it 'updates the registry' do
      update_params = { 'name' => 'biz' }
      patch :update, { id: registry.id, format: :json }.merge(update_params)
      expect(registry.reload.name).to eq 'biz'
    end

    it 'returns an HTTP 204 status code' do
      put :update, id: registry.id, format: :json
      expect(response.status).to eq 204
    end

    context 'when the record cannot be found' do
      it 'returns an HTTP 500 status code' do
        put :update, id: registry.id + 777, format: :json
        expect(response.status).to eq 500
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'removes the supplied DeploymentTarget' do
      expect do
        delete :destroy, id: registry.id, format: :json
      end.to change { Registry.count }.by(-1)
    end

    it 'returns an HTTP 204 status code' do
      delete :destroy, id: registry.id, format: :json
      expect(response.status).to eq 204
    end

    context 'when the destroy fails' do
      it 'returns an HTTP 500 status code' do
        delete :destroy, id: registry.id + 777, format: :json
        expect(response.status).to eq 500
      end
    end
  end
end
