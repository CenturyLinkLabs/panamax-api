require 'spec_helper'

describe ApiModel do

  let(:attr_accessors) { [:name, :age] }

  subject do
    Class.new(described_class).tap do |cls|
      cls.attr_accessor *attr_accessors
    end
  end

  describe '.attributes' do
    it 'returns all values set via attr_accessor' do
      expect(subject.attributes).to eq attr_accessors
    end
  end

  describe '#initialize' do

    let(:attrs) { { name: 'foo', age: 40 } }

    it 'sets specified attributes on model' do
      model = subject.new(attrs)
      expect(model.name).to eq attrs[:name]
      expect(model.age).to eq attrs[:age]
    end
  end

  describe '#attributes' do
    it 'returns all values set via attr_accessor' do
      expect(subject.new.attributes).to eq attr_accessors
    end
  end
end
