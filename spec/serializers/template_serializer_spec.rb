require 'spec_helper'

describe TemplateSerializer do
  let(:template) { Template.new }

  it 'exposes the attributes to be jsonified' do
    serialized = described_class.new(template).as_json
    expected_keys = [
      :id,
      :name,
      :description,
      :keywords,
      :recommended,
      :icon,
      :images,
      :image_count,
      :from,
      :created_at,
      :updated_at
    ]
    expect(serialized.keys).to match_array expected_keys
  end

end
