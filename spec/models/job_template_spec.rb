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

  describe '.load_templates' do
    let(:child) { double(:child, read: '') }
    let(:pathname) { double(:pathname) }

    before do
      allow(pathname).to receive(:each_child).and_yield(child)
    end

    it 'invokes the JobTemplateBuilder' do
      expect(JobTemplateBuilder).to receive(:create).once
      described_class.load_templates(pathname)
    end

  end

end
