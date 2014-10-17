require 'spec_helper'

describe IsValidUrlValidator do

  let(:record) { Registry.new }
  let(:attribute) { 'endpoint' }

  subject { described_class.new(attributes: [attribute]) }

  context 'when the attribute is valid' do

    before do
      subject.validate_each(record, attribute, value)
    end

    context 'when the endpoint is an IP' do
      let(:value) { 'http://127.0.0.1' }

      it 'does not set an error on the record' do
        expect(record.errors).to be_empty
      end
    end

    context 'when the endpoint is a URL' do
      let(:value) { 'http://foo.com' }

      it 'does not set an error on the record' do
        expect(record.errors).to be_empty
      end
    end

    context 'when the endpoint contains localhost' do
      let(:value) { 'http://localhost' }

      it 'does not set an error on the record' do
        expect(record.errors).to be_empty
      end
    end


    context 'when the endpoint contains a port' do
      let(:value) { 'http://myregistry:5000' }

      it 'does not set an error on the record' do
        expect(record.errors).to be_empty
      end
    end
  end

  context 'when the attribute it not valid' do

    before do
      subject.validate_each(record, attribute, value)
    end

    context 'when a URI::Parser error occurs' do

      let(:value) { [] }

      it 'sets an error on the record' do
        expect(record.errors).to_not be_empty
      end

      it 'stops validating after the error is received' do
        expect(record.errors[attribute].size).to eq 1
      end
    end

    context 'when the scheme is missing' do

      let(:value) { 'foo.com' }

      it 'should set an error on the record' do
        expect(record.errors).to_not be_empty
      end
    end

    context 'when there is no host' do

      let(:value) { 'https://' }

      it 'should set an error on the record' do
        expect(record.errors).to_not be_empty
      end
    end
  end

end
