require 'spec_helper'

describe UsersController do

  describe '#update' do

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
