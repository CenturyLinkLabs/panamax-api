require 'spec_helper'

describe PanamaxAgent::Panamax::Client::Components do

  let(:fake_registry_client) { double(:fake_registry_client) }
  subject { PanamaxAgent::Panamax::Client.new(registry_client: fake_registry_client) }

  let(:expected_components) do
    [
      {
        'panamax-agent' => [
          {
            'versions' => {
              '0.0.1' => ''
            }
          }
        ]
      },
      {
        'panamax-ui' => [
          {
            'versions' => {
              '0.0.1' =>
                   'c621aba88fcdd1fc78d1be596efe91763edc69e8f6aefbd9e719dd556a6d65f0',
              '0.0.2' =>
                'c621aba88fcdd1fc78d1be596efe91763edc69e8f6aefbd9e719dd556a6d65f0',
              '0.0.3' =>
                'e7638cac6322860b5d1d6d93cb7f0cbd6430c7da29dbc39935589196e2c341b0',
              '0.0.4' =>
                '373bc7e476c9ddfe33df55d8ad2c03574804e3fb4097420210df6dd1fe690fd7',
              'dev' => '373bc7e476c9ddfe33df55d8ad2c03574804e3fb4097420210df6dd1fe690fd7',
              'latest' =>
                '373bc7e476c9ddfe33df55d8ad2c03574804e3fb4097420210df6dd1fe690fd7'
            }
          }
        ]
      },
      {
        'panamax-api' => [
          {
            'versions' => {
              '0.0.1' =>
                 '66aa01032841e76126a9a31236194de563ef3f83bbfa1747e2a52b2861fe2b29',
              '0.0.2' =>
                 'ff1a3f25e0345bafadb32c1d268a300c73ced377b09f2f8d28fc7a0228e08bbf',
              '0.0.3' =>
                 'ff1a3f25e0345bafadb32c1d268a300c73ced377b09f2f8d28fc7a0228e08bbf',
              '0.0.4' =>
                 'ff1a3f25e0345bafadb32c1d268a300c73ced377b09f2f8d28fc7a0228e08bbf',
              '0.1.0' =>
                 'ff1a3f25e0345bafadb32c1d268a300c73ced377b09f2f8d28fc7a0228e08bbf',
              '0.1.1' =>
                 '08f5aff7f4eca2ce57c2d49fa1cefafe2b023eb18a7e4e6b1a599a350fc0a76a',
              '0.1.2' =>
                 'cc09435b159c8e6111928dc30e2188ae4b94c5cf734dfa8770b04e535f71aba8',
              'dev' => 'cc09435b159c8e6111928dc30e2188ae4b94c5cf734dfa8770b04e535f71aba8',
              'latest' =>
                 'cc09435b159c8e6111928dc30e2188ae4b94c5cf734dfa8770b04e535f71aba8'
            }
          }
        ]
      }
    ]
  end

  before do
    PanamaxAgent::Registry::Client.stub(:new).and_return(fake_registry_client)
    fake_registry_client.stub(:list_repository_tags)
      .with('panamax-ui')
      .and_return(expected_components[1]['panamax-ui'][0]['versions'])
    fake_registry_client.stub(:list_repository_tags)
      .with('panamax-api')
      .and_return(expected_components[2]['panamax-api'][0]['versions'])
  end

  describe '#list_components' do

    it 'returns the metadata for all components' do
      expect(subject.list_components).to eql(expected_components)
    end
  end

  describe '#get_component' do

    it 'returns the metadata info for the panamax agent' do
      expect(subject.get_component('panamax-agent')).to eq expected_components[0]['panamax-agent']
    end

    it 'returns the metadata info for the panamax ui component' do
      expect(subject.get_component('panamax-ui')).to eql(expected_components[1]['panamax-ui'])
    end

    it 'returns the metadata info for the panamax api component' do
      expect(subject.get_component('panamax-api')).to eql(expected_components[2]['panamax-api'])
    end

    it 'returns empty array for non panamax component' do
      expect(subject.get_component('not-valid')).to eq []
    end
  end
end
