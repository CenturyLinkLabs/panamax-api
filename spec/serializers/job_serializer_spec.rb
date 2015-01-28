require 'spec_helper'

describe JobSerializer do
  fixtures :jobs, :job_steps

  let(:state) { { 'status' => 'running', 'stepsCompleted' => '1' } }
  let(:fake_dray_client) { double(:fake_dray_client, get_job: state) }

  before do
    allow(PanamaxAgent::Dray::Client).to receive(:new).and_return(fake_dray_client)
  end

  it 'exposes the attributes to be jsonified' do
    serialized = described_class.new(jobs(:cluster_job)).as_json
    expected_keys = [:id, :key, :completed_steps, :status, :steps, :job_template_id]
    expect(serialized.keys).to match_array expected_keys
  end

  it 'retreives completed steps from the job being serialized' do
    serialized = described_class.new(jobs(:cluster_job))
    expect(serialized.completed_steps).to eq jobs(:cluster_job).completed_steps
  end

  it 'retreives status from the job being serialized' do
    serialized = described_class.new(jobs(:cluster_job))
    expect(serialized.status).to eq jobs(:cluster_job).status
  end

end
