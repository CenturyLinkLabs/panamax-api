require 'spec_helper'

describe HasEnvironmentVariableValuesValidator do

  let(:record) { Job.new }
  let(:attribute) { 'environment' }

  subject { described_class.new(attributes: [attribute]) }

  context 'when the attribute is valid' do

    let(:value) do
      [
        { 'variable' => 'foo', 'value' => 'bar' }
      ]
    end

    it 'returns no errors for environment variables with values' do
      subject.validate_each(record, attribute, value)
      expect(record.errors).to be_empty
    end

  end

  context 'when the attribute is invalid' do

    let(:value) do
      [
        { 'variable' => 'foo' }
      ]
    end

    it 'should set an error on the record' do
      subject.validate_each(record, attribute, value)
      expect(record.errors).to_not be_empty
    end

  end

end
