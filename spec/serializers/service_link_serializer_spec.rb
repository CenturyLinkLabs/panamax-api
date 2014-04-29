require 'spec_helper'

describe ServiceLinkSerializer do
  let(:service) { Service.new }
  let(:service_link_model) { ServiceLink.new }

  before do
    service_link_model.linked_to_service = service
  end

  it 'exposes the attributes to be jsonified' do
    serialized = described_class.new(service_link_model).as_json
    expected_keys = [
      :service_id,
      :service_name,
      :alias
    ]
    expect(serialized.keys).to match_array expected_keys
  end
end

