require 'spec_helper'

describe ServiceSerializer do
  let(:service_model) { Service.new }

  it 'exposes the attributes to be jsonified' do
    serialized = described_class.new(service_model).as_json
    expected_keys = [
      :id,
      :name,
      :internal_name,
      :description,
      :from,
      :links,
      :environment,
      :ports,
      :expose,
      :volumes,
      :command,
      :app,
      :categories,
      :active_state,
      :load_state,
      :sub_state,
      :type,
      :errors,
      :docker_status
    ]
    expect(serialized.keys).to match_array expected_keys
  end
end
