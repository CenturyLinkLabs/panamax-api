require 'spec_helper'

describe AppCategorySerializer do
  let(:category_model) { AppCategory.new }

  it 'exposes the attributes to be jsonified' do
    serialized = described_class.new(category_model).as_json
    expected_keys = [
      :id,
      :name,
      :position
    ]
    expect(serialized.keys).to match_array expected_keys
  end
end
