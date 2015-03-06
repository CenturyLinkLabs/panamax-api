require 'spec_helper'

describe JobStepLiteSerializer do
  let(:job_step) { JobStep.new }

  it 'exposes the attributes to be serialized' do
    serialized = described_class.new(job_step).as_json
    expected_keys = [:source, :beginDelimiter, :endDelimiter]
    expect(serialized.keys).to match_array expected_keys
  end
end
