require 'spec_helper'

describe ArrayItemWrapper do

  using ArrayItemWrapper

  subject { [1, 2, 3] }

  let(:wrapper) do
    Class.new do
      attr_reader :item
      def initialize(item); @item = item; end
    end
  end

  it 'adds a #wrap method to the Array' do
    expect { subject.wrap(wrapper) }.to_not raise_error
  end

  describe '#wrap' do

    it 'instantiates a wrapper for each item in the array' do
      expect(wrapper).to receive(:new).exactly(subject.count).times
      subject.wrap(wrapper)
    end

    it 'returns wrapped array elements' do
      result = subject.wrap(wrapper)

      expect(result).to be_kind_of(Array)
      expect(result.count).to eq subject.count
      expect(result.first).to be_kind_of(wrapper)
      expect(result.first.item).to eq subject.first
    end
  end
end
