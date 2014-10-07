require 'spec_helper'

describe RegistriesController do

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
end
