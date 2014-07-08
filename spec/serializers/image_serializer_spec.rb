require 'spec_helper'

describe ImageSerializer do
  let(:image_model) { Image.new }

  it 'exposes the attributes to be jsonified' do
    serialized = described_class.new(image_model).as_json
    expected_keys = [
      :category,
      :name,
      :repository,
      :tag,
      :description,
      :type,
      :expose,
      :ports,
      :links,
      :environment,
      :volumes
    ]
    expect(serialized.keys).to match_array expected_keys
  end

  it 'rolls up the image categories into a singular category in the json' do
    image_model.categories = ['foo']
    serialized = described_class.new(image_model).as_json
    expect(serialized[:category]).to eq image_model.categories.first
  end
end
