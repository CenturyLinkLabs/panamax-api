require 'spec_helper'

describe PanamaxAgent::Error do

  let(:message) { 'some message' }
  let(:error_code) { 12345 }
  let(:cause) { 'user error' }

  subject { PanamaxAgent::Error.new(message, error_code, cause) }

  it { should respond_to(:message) }
  it { should respond_to(:error_code) }
  it { should respond_to(:cause) }

  describe '#initialize' do

    it 'saves the passed-in message' do
      expect(subject.message).to eq message
    end

    it 'saves the passed-in error code' do
      expect(subject.error_code).to eq error_code
    end

    it 'saves the passed-in cause' do
      expect(subject.cause).to eq cause
    end
  end
end
