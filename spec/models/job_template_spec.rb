require 'spec_helper'

describe JobTemplate do
  it { should have_many(:job_steps) }
  it { should respond_to?(:cluster_job_templates) }

  let(:step_a) { JobStep.create(order: 1) }
  let(:step_b) { JobStep.create(order: 2) }
  let(:steps) { [step_b, step_a] } # out of order
  let(:template) { JobTemplate.create(job_steps: steps) }

  subject { Job.new(job_template: template) }

  it 'returns job steps in order' do
    expect(subject.job_steps).to match_array([step_b, step_a])
    expect(subject.job_steps.first).to eq step_a
    expect(subject.job_steps.second).to eq step_b
  end
end
