require 'spec_helper'

describe HasContainerNamesValidator do

  let(:record) { Image.new }
  let(:attribute) { 'volumes_from' }

  subject { described_class.new(attributes: [attribute]) }

  context 'when the attribute is valid' do

    let(:value) do
      [
          { 'container_name' => 'foodata' },
          { 'container_name' => 'bardata' }
      ]
    end

    it 'returns no errors for volumes_from with container names' do
      subject.validate_each(record, attribute, value)
      expect(record.errors).to be_empty
    end

  end

  context 'when the attribute is invalid' do

    let(:value) do
      [
          { 'container_name' => '' },
          { 'container_name' => '' }
      ]
    end

    it 'should set an error on the record' do
      subject.validate_each(record, attribute, value)
      expect(record.errors[attribute]).to include "container name can't be blank"
    end

    it 'should quit validating after the first error is detected' do
      subject.validate_each(record, attribute, value)
      expect(record.errors[attribute].size).to eq 1
    end

  end

end
