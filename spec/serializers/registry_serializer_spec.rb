require 'spec_helper'

describe RegistrySerializer do
  let(:registry_model) { Registry.new }

  it 'exposes the attributes to be jsonified' do
    serialized = described_class.new(registry_model).as_json
    expected_keys = [
      :id,
      :name,
      :endpoint_url,
      :enabled
    ]
    expect(serialized.keys).to match_array expected_keys
  end
end
