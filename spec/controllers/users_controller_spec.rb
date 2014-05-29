require 'spec_helper'

describe UsersController do

  describe '#show' do

    it 'returns the user instance' do
      get :show, format: :json
      expect(response.body).to eq User.instance.to_json
    end

    it 'returns a 200 status code' do
      get :show, format: :json
      expect(response.status).to eq 200
    end
  end

  describe '#update' do

    before do
      # Neuter model validations
      User.any_instance.stub(:access_token_scope)
    end

    let(:params) { { github_access_token: 'token' } }

    it 'changes the user attributes' do
      put :update, params.merge(format: :json)

      expect(User.instance.github_access_token).to eq(
        params[:github_access_token])
    end

    it 'returns a 204 status code' do
      put :update, params.merge(format: :json)
      expect(response.status).to eq 204
    end
  end

end
