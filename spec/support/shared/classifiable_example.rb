require 'spec_helper'

shared_examples 'a classifiable model' do

  let(:model) { described_class.new }
  let(:default_type) do
    PanamaxApi::TYPES.find { |type| type['default'] }['name']
  end

  context 'when the type field is nil' do

    it 'sets the type to be the default value' do
      model.valid?
      expect(model.type).to eq default_type
    end
  end

  context 'when the type field is an invalid value' do

    before do
      model.type = 'foobar'
    end

    it 'sets the type to be the default value' do
      model.valid?
      expect(model.type).to eq default_type
    end
  end

  context 'when the type field is a valid value' do

    before do
      model.type = PanamaxApi::TYPES.last['name']
    end

    it 'leaves the value as-is' do
      model.valid?
      expect(model.type).to eq PanamaxApi::TYPES.last['name']
    end
  end

end
