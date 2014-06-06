require 'spec_helper'

describe PanamaxController do

  describe '#show' do
    let(:components) do
      {
        'panamax-agent' =>
          { 'versions' =>
            { '0.0.1' => 'ddddd' }
          },
        'panamax-ui' =>
          { 'versions' =>
            { '0.0.1'  => 'cccccc' }
          },
        'panamax-api' =>
          { 'versions' =>
            { '0.0.1'  => 'hhhhhh' }
          }
      }
    end
    let(:client) { double(:client, list_components: components) }

    before do
      PanamaxAgent.stub(panamax_client: client)
    end

    it 'invokes list_components on panamax client' do
      expect(client).to receive(:list_components)
      get :show, format: :json
    end

    it 'returns the components' do
      get :show, format: :json
      expect(response.body).to eq components.to_json
    end

    it 'returns a 200 status code' do
      get :show, format: :json
      expect(response.status).to eq 200
    end

  end
end
