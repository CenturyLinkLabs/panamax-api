require 'spec_helper'

describe SharedVolumeSerializer do
  let(:service) { Service.new }
  let(:shared_volume_model) { SharedVolume.new }

  before do
    shared_volume_model.exported_from_service = service
  end

  it 'exposes the attributes to be jsonified' do
    serialized = described_class.new(shared_volume_model).as_json
    expected_keys = [
      :service_id,
      :service_name,
      :errors
    ]
    expect(serialized.keys).to match_array expected_keys
  end
end
