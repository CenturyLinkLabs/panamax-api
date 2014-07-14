require 'spec_helper'

describe HasContainerPathsValidator do

  let(:record) { Image.new }
  let(:attribute) { 'volumes' }

  subject { described_class.new(attributes: [attribute]) }

  context 'when the attribute is valid' do

    let(:value) do
      [
        { 'host_path' => '/foo', 'container_path' => '/bar' },
        { 'host_path' => '/baz', 'container_path' => '/quux' }
      ]
    end

    it 'returns no errors volumes with container paths' do
      subject.validate_each(record, attribute, value)
      expect(record.errors).to be_empty
    end

  end

  context 'when the attribute is invalid' do

    let(:value) do
      [
        { 'host_path' => '/foo' },
        { 'host_path' => '/bar' }
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
