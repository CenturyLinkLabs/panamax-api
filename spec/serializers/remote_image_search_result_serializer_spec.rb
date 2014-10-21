require 'spec_helper'

describe RemoteImageSearchResultSerializer do
  let(:image_model) { RemoteImage.new }

  it 'exposes the attributes to be jsonified' do
    serialized = described_class.new(image_model).as_json
    expected = [:source, :description, :is_official, :is_trusted, :star_count, :registry_id, :registry_name]
    expect(serialized.keys).to match_array expected
  end
end
