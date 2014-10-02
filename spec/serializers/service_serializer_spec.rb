require 'spec_helper'

describe ServiceSerializer do

  let(:service_model) { Service.new }

  let(:image_status) do
    double(:image_status,
      info: {
        'Config' => {
          'ExposedPorts' => { '3000/tcp' => {} }
        }
      })
  end

  before do
    Docker::Image.stub(:get).and_return(image_status)
  end

  it 'exposes the attributes to be jsonified' do
    serialized = described_class.new(service_model).as_json
    expected_keys = [
      :id,
      :name,
      :description,
      :from,
      :links,
      :environment,
      :ports,
      :expose,
      :volumes,
      :volumes_from,
      :command,
      :app,
      :categories,
      :active_state,
      :load_state,
      :sub_state,
      :type,
      :errors,
      :docker_status,
      :default_exposed_ports
    ]
    expect(serialized.keys).to match_array expected_keys
  end
end
