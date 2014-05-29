require 'spec_helper'

describe AppSerializer do
  let(:app_model) { App.new }
  let(:category_model) { AppCategory.new }

  before { app_model.categories << category_model }

  it 'exposes the attributes to be jsonified' do
    serialized = described_class.new(app_model).as_json
    expected_keys = [
      :id,
      :name,
      :from,
      :categories,
      :errors,
      :services,
      :documentation
    ]
    expect(serialized.keys).to match_array expected_keys
  end
end
