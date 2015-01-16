require 'spec_helper'

describe JobLiteSerializer do
  fixtures :jobs, :job_templates

  it 'exposes the attributes to be jsonified' do
    serialized = described_class.new(jobs(:cluster_job)).as_json
    expected_keys = [:name, :environment, :steps]
    expect(serialized.keys).to match_array expected_keys
  end

  it 'retreives the name from the job template serialized' do
    serialized = described_class.new(jobs(:cluster_job))
    expect(serialized.name).to eq jobs(:cluster_job).job_template.name
  end

  it 'retreives environment variables from the job being serialized' do
    serialized = described_class.new(jobs(:cluster_job))
    expect(serialized.environment).to eq jobs(:cluster_job).environment
  end

end
