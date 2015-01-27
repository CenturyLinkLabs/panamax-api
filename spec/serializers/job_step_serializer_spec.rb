require 'spec_helper'

describe JobStepSerializer do
  let(:job_step) { JobStep.new }

  it 'exposes the attributes to be serialized' do
    serialized = described_class.new(job_step).as_json
    expected_keys = [:id, :order, :name, :source, :environment]
    expect(serialized.keys).to match_array expected_keys
  end
end
