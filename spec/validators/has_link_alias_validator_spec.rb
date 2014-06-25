require 'spec_helper'

describe HasLinkAliasValidator do

  let(:record) { Image.new }
  let(:attribute) { 'links' }

  subject { described_class.new(attributes: [attribute]) }

  context 'when the attribute is valid' do

    let(:value) do
      [
        { 'service' => 'foo', 'alias' => 'bar' },
        { 'service' => 'baz', 'alias' => 'quux' }
      ]
    end

    it 'returns no errors for links with aliases' do
      subject.validate_each(record, attribute, value)
      expect(record.errors).to be_empty
    end

  end

  context 'when the attribute is invalid' do

    let(:value) do
      [
        { 'service' => 'foo' },
        { 'service' => 'bar' }
      ]
    end

    it 'should set an error on the record' do
      subject.validate_each(record, attribute, value)
      expect(record.errors).to_not be_empty
    end

    it 'should quit validating after the first error is detected' do
      subject.validate_each(record, attribute, value)
      expect(record.errors[attribute].size).to eq 1
    end

  end

end
