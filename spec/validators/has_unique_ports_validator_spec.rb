require 'spec_helper'

describe HasUniquePortsValidator do

  let(:record) { Service.new }
  let(:attribute) { 'ports' }

  subject { described_class.new(attributes: [attribute]) }

  context 'when host ports are unique' do

    let(:value) do
      [
        { 'host_port' => 80, 'container_port' => 8080 },
        { 'host_port' => 81, 'container_port' => 7070 }
      ]
    end

    it 'returns no errors' do
      subject.validate_each(record, attribute, value)
      expect(record.errors).to be_empty
    end

  end

  context 'when host ports are not unique, but have different protocols' do
    let(:value) do
      [
        { 'host_port' => 80, 'proto' => 'TCP' },
        { 'host_port' => 80, 'proto' => 'UDP' }
      ]
    end

    it 'returns no errors' do
      subject.validate_each(record, attribute, value)
      expect(record.errors).to be_empty
    end

  end

  context 'when both host ports are blank' do
    let(:value) do
      [
        { 'container_port' => 82, 'host_port' => '', 'proto' => 'TCP' },
        { 'container_port' => 80, 'host_port' => '', 'proto' => 'TCP' }
      ]
    end

    it 'returns no errors' do
      subject.validate_each(record, attribute, value)
      expect(record.errors).to be_empty
    end

  end

  context 'when host ports are not unique' do

    let(:value) do
      [
        { 'host_port' => 80 },
        { 'host_port' => 80 }
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
