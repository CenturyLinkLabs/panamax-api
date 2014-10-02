require 'spec_helper'

describe DeploymentTargetsController do

  let(:deployment_target) { deployment_targets(:target1) }

  describe 'GET #index' do
    it 'returns a list of deployment targets' do
      get :index, format: :json
      expect(JSON.parse(response.body)).to be_an Array
    end

    it 'returns an HTTP 200 status code' do
      get :index, format: :json
      expect(response.status).to eq 200
    end
  end

  describe 'GET #show' do
    context 'when the desired target exists' do
      it 'queries for the DeploymentTarget with the supplied identifier' do
        get :show, id: deployment_target.id, format: :json
        expect(response.body).to eq DeploymentTargetSerializer.new(deployment_target).to_json
      end

      it 'returns an HTTP 200 status code' do
        get :show, id: deployment_target.id, format: :json
        expect(response.status).to eq 200
      end
    end

    context 'when the desired target does not exist' do
      before do
        DeploymentTarget.stub(:find).with('13').and_raise(ActiveRecord::RecordNotFound)
      end

      it 'returns an HTTP 500 status code' do
        get :show, id: 13, format: :json
        expect(response.status).to eq 500
      end
    end
  end

  describe 'POST #create' do
    let(:create_params) do
      auth_array = [
        'http://endpoint.example.com',
        'admin',
        'password',
        'cert contents'
      ]
      {
        'name' => 'dev',
        'auth_blob' => Base64.encode64(auth_array.join('|'))
      }
    end

    context 'when creation is successful' do
      it 'creates the deployment target' do
        expect do
          post :create, create_params.merge(format: :json)
        end.to change { DeploymentTarget.count }.by(1)
      end

      it 'returns an HTTP 201 status code' do
        post :create, create_params.merge(format: :json)
        expect(response.status).to eq 201
      end
    end
  end

  describe 'PATCH/PUT #update' do
    it 'updates the deployment target' do
      update_params = { 'name' => 'production backup' }
      patch :update, { id: deployment_target.id, format: :json }.merge(update_params)
      expect(deployment_target.reload.name).to eq 'production backup'
    end

    it 'returns an HTTP 204 status code' do
      put :update, id: deployment_target.id, format: :json
      expect(response.status).to eq 204
    end

    context 'when the record cannot be found' do
      it 'returns an HTTP 500 status code' do
        put :update, id: deployment_target.id + 777, format: :json
        expect(response.status).to eq 500
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'removes the supplied DeploymentTarget' do
      expect do
        delete :destroy, id: deployment_target.id, format: :json
      end.to change { DeploymentTarget.count }.by(-1)
    end

    it 'returns an HTTP 204 status code' do
      delete :destroy, id: deployment_target.id, format: :json
      expect(response.status).to eq 204
    end

    context 'when the destroy fails' do
      it 'returns an HTTP 500 status code' do
        delete :destroy, id: deployment_target.id + 777, format: :json
        expect(response.status).to eq 500
      end
    end
  end
end
