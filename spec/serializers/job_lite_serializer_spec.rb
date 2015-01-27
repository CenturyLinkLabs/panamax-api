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

  context 'when serializing job environment variables' do
    let(:new_env_var) { { 'variable' => 'foo', 'value' => 8080 } }

    it 'stringifies the job environment variable values' do
      some_job = jobs(:cluster_job)
      some_job.environment << new_env_var
      serialized = described_class.new(some_job)
      expect(serialized.environment.first['value']).to eq '8080'
    end
  end

end
