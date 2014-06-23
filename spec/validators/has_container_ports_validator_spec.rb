require 'spec_helper'

describe HasContainerPortsValidator do

  subject { described_class.new(attributes: [:ports_attr]) }

  let(:record) { Image.new }
  let(:attribute) { 'ports' }

  context 'when the attribute is valid' do

    let(:value) do
      [
        { 'host_port' => 80, 'container_port' => 8080 },
        { 'host_port' => 81, 'container_port' => 7070 }
      ]
    end

    it 'returns no errors for ports with container ports' do
      subject.validate_each(record, attribute, value)
      expect(record.errors).to be_empty
    end
  end

  context 'when the attribute is invalid' do

    let(:value) do
      [
        { 'host_port' => 80 },
        { 'host_port' => 81 }
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
