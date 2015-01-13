require 'spec_helper'

describe JobBuilder::FromTemplate do
  fixtures :job_templates

  let(:job_template) { job_templates(:cluster_job_template) }
  let(:job) { Job.new }
  let(:converter) { double(:converter, to_job: job) }

  before do
    allow_any_instance_of(Converters::JobTemplateConverter).to receive(:to_job).and_return(job)
    allow(JobTemplate).to receive(:find).with(job_template.id).and_return(job_template)
  end

  describe '.create_job' do
    context 'when override options are passed' do
      let(:override) { {} }
      let(:override_template) { JobTemplate.new }

      before do
        allow(JobTemplateBuilder).to receive(:create).with(override, false).and_return(override_template)
      end

      it 'creates a job template from the override' do
        expect(JobTemplateBuilder).to receive(:create).with(override, false).and_return(override_template)
        described_class.create_job(template_id: job_template.id, override: override)
      end

      it 'overrides the template with the override template' do
        expect(job_template).to receive(:override).with(override_template)
        described_class.create_job(template_id: job_template.id, override: override)
      end

    end

    it 'instantiates a converter with the job_template' do
      expect(Converters::JobTemplateConverter).to(
        receive(:new).with(job_template).and_return(converter))

      described_class.create_job(template_id: job_template.id)
    end

    it 'persists a new job' do
      expect do
        described_class.create_job(template_id: job_template.id)
      end.to change(Job, :count).by(1)
    end

    it 'returns the new job' do
      expect(described_class.create_job(template_id: job_template.id)).to eql job
    end
  end

end
