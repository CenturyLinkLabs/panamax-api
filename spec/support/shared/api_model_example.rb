require 'spec_helper'

shared_examples 'an api model' do

  let(:model) { described_class.new }

  describe '.attributes' do
    it 'exposes .attributes class method' do
      expect(described_class).to respond_to :attributes
    end
  end

  describe '#attributes' do
    it { should respond_to :attributes }

    it 'returns the same result as the class-level attributes method' do
      expect(subject.attributes).to eq described_class.attributes
    end
  end

  describe 'ActiveModel::Serialization' do
    it { should respond_to :serializable_hash }
  end
end
