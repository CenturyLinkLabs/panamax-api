require 'spec_helper'

describe IsNumericListValidator do

  let(:record) { Service.new }
  let(:attribute) { 'expose' }

  subject { described_class.new(attributes: [attribute]) }

  context 'when the attribute is valid' do

    let(:value) do
      %w(1111 2222)
    end

    it 'returns no errors for numeric ports' do
      subject.validate_each(record, attribute, value)
      expect(record.errors).to be_empty
    end

  end

  context 'when the attribute is invalid' do

    let(:value) do
      %w('' '' '')
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
