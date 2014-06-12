require 'spec_helper'

describe PanamaxController do

  before do
    PanamaxAgent.stub(panamax_client: client)
  end

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

  describe '#metrics' do
    let(:metrics) do
      {
        'host_metrics' =>
          {
            'load_average'  => '0.35',
            'cpu_idle'      => '90.0',
            'memory_free'   => '293.073',
            'cpu_cores'     => '2',
            'last_updated'  => '2014/06/04 02:12:51'
          }
      }
    end

    let(:client) { double(:client, list_host_metrics: metrics) }

    it 'invokes list_host_metrics on panamax client' do
      expect(client).to receive(:list_host_metrics)
      get :metrics, format: :json
    end

    it 'returns the host metrics' do
      get :metrics, format: :json
      expect(response.body).to eq metrics.to_json
    end

    it 'returns a 200 status code' do
      get :metrics, format: :json
      expect(response.status).to eq 200
    end

  end
end
