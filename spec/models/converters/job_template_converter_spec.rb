require 'spec_helper'

describe Converters::JobTemplateConverter do
  fixtures :job_templates

  subject { described_class.new(job_templates(:cluster_job_template)) }

  describe '#to_job' do
    it 'creates a job from the given template' do
      expect(subject.to_job).to be_a Job
    end

    it "converts the JobTemplate's JobSteps to the Job's steps" do
      expect(subject.to_job.steps.size).to eq job_templates(:cluster_job_template).steps.size
    end
  end

end
