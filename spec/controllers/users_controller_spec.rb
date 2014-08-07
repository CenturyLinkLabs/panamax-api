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

    let(:params) { { github_access_token: 'token', subscribe: '1' } }

    context 'when the user is successfully updated' do

      before do
        # Neuter model validations
        User.any_instance.stub(:access_token_scope)
        User.any_instance.stub(:valid?).and_return(true)
        User.any_instance.stub(:subscribe)
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

      context 'when the subscribe flag is set to 1' do
        it 'subscribes the user' do
          expect_any_instance_of(User).to receive(:subscribe)
          put :update, params.merge(subscribe: 1, format: :json)
        end
      end

      context 'when the subscribe flag is set to "1"' do
        it 'subscribes the user' do
          expect_any_instance_of(User).to receive(:subscribe)
          put :update, params.merge(subscribe: '1', format: :json)
        end
      end

      context 'when the subscribe flag is set to true' do
        it 'subscribes the user' do
          expect_any_instance_of(User).to receive(:subscribe)
          put :update, params.merge(subscribe: true, format: :json)
        end
      end

      context 'when the subscribe flag is set to "true"' do
        it 'subscribes the user' do
          expect_any_instance_of(User).to receive(:subscribe)
          put :update, params.merge(subscribe: 'true', format: :json)
        end
      end

      context 'when the subscribe flag is set to "0"' do
        it 'does NOT subscribe the user' do
          expect_any_instance_of(User).to_not receive(:subscribe)
          put :update, params.merge(subscribe: '0', format: :json)
        end
      end

      context 'when the subscribe flag is set to false' do
        it 'does NOT subscribe the user' do
          expect_any_instance_of(User).to_not receive(:subscribe)
          put :update, params.merge(subscribe: false, format: :json)
        end
      end
    end

    context 'when the user fails validation' do

      before do
        user = User.new
        user.stub(:update)
        user.stub(:valid?).and_return(false)
        user.errors.add(:base, 'boom')

        User.stub(:instance).and_return(user)
      end

      it 'returns the error message' do
        put :update, params.merge(format: :json)
        expect(response.body).to include 'boom'
      end

      it 'does NOT subscribe the user' do
        User.any_instance.should_not_receive(:subscribe)
        put :update, params.merge(format: :json)
      end

      it 'returns a 422 status code' do
        put :update, params.merge(format: :json)
        expect(response.status).to eq 422
      end
    end
  end

  context 'handling Faraday::Errror::ConnectionFailed exceptions' do

    controller(UsersController) do
      def index
        raise Faraday::Error::ConnectionFailed, 'oops'
      end
    end

    it 'returns the githb connection error message' do
      get :index

      expect(response.status).to eq 500
      expect(response.body).to eq(
        { message: I18n.t(:github_connection_error) }.to_json)
    end
  end

end
