require 'spec_helper'

describe RepositorySerializer do
  let(:image_model) { LocalImage.new(id: 'foo') }

  it 'exposes the attributes to be jsonified' do
    serialized = described_class.new(image_model).as_json
    expected = [:id, :tags]
    expect(serialized.keys).to match_array expected
  end
end
