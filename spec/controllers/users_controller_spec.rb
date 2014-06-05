require 'spec_helper'

describe UsersController do

  describe '#show' do

    it 'returns the user instance' do
      get :show, format: :json
      expect(response.body).to eq UserSerializer.new(User.instance).to_json
    end

    it 'returns a 200 status code' do
      get :show, format: :json
      expect(response.status).to eq 200
    end
  end

  describe '#update' do

    let(:params) { { github_access_token: 'token' } }

    context 'when the user is successfully updated' do

      before do
        # Neuter model validations
        User.any_instance.stub(:access_token_scope)
      end

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

    context 'when the user fails validation' do

      before do
        user = User.new
        user.stub(:update)
        user.errors.add(:base, 'boom')

        User.stub(:instance).and_return(user)
      end

      it 'returns the error message' do
        put :update, params.merge(format: :json)
        expect(response.body).to include 'boom'
      end

      it 'returns a 422 status code' do
        put :update, params.merge(format: :json)
        expect(response.status).to eq 422
      end
    end
  end

end
