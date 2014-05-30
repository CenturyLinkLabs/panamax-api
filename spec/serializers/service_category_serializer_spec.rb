require 'spec_helper'

describe ServiceCategorySerializer do
  let(:service_category) { ServiceCategory.new }
  let(:app_category) { AppCategory.new }

  before { service_category.app_category = app_category }

  it 'exposes the attributes to be jsonified' do
    serialized = described_class.new(service_category).as_json
    expected_keys = [
      :id,
      :name,
      :position
    ]
    expect(serialized.keys).to match_array expected_keys
  end
end
