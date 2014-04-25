require 'spec_helper'

describe ServiceLiteSerializer do
  let(:service_model) { Service.new }

  it 'exposes the attributes to be jsonified' do
    serialized = described_class.new(service_model).as_json
    expected_keys = [
      :id,
      :name,
      :categories,
      :errors
    ]
    expect(serialized.keys).to match_array expected_keys
  end
end
