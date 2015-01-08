require 'spec_helper'

describe JobTemplateBuilder::FromJson do

  let(:job_template) { Rails.root.join('spec', 'support', 'fixtures', 'brightbox.yml').read }

  subject { described_class.new job_template }

  context '.create_template' do
    it 'creates a job template from the data' do
      expect(subject.create_template).to be_a(JobTemplate)
    end

    it 'persists the template' do
      expect(subject.create_template).to be_persisted
    end
  end

end
