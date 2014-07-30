require 'spec_helper'

describe LocalImageSearchResultSerializer do
  let(:image_model) { LocalImage.new(id: 'foo') }

  it 'exposes the attributes to be jsonified' do
    serialized = described_class.new(image_model).as_json
    expected = [:source, :description, :is_official, :is_trusted, :star_count]
    expect(serialized.keys).to match_array expected
  end
end
