require 'spec_helper'

describe JobTemplate do
  it 'has many steps' do
    expect(subject).to have_many(:steps)
  end

  it 'responds to .cluster_job_templates' do
    expect(described_class.respond_to?(:cluster_job_templates)).to be_truthy
  end

  it 'responds to #environment' do
    expect(subject.respond_to?(:environment)).to be_truthy
  end

  it 'responds to #vendor' do
    expect(subject.respond_to?(:vendor)).to be_truthy
  end

  it 'responds to #adapter' do
    expect(subject.respond_to?(:adapter)).to be_truthy
  end

  let(:step_a) { JobTemplateStep.create(order: 1) }
  let(:step_b) { JobTemplateStep.create(order: 2) }

  describe '#steps' do
    let(:steps) { [step_b, step_a] } # out of order
    subject { described_class.create(steps: steps) }

    it 'returns job steps in order' do
      subject.reload
      expect(subject.steps).to match_array([step_b, step_a])
      expect(subject.steps.first).to eq step_a
      expect(subject.steps.second).to eq step_b
    end
  end

  describe '.default_type' do
    it 'is the cluster type' do
      expect(described_class.default_type).to eq 'ClusterJobTemplate'
    end
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

  describe '#override' do
    let(:job_template) do
      JobTemplate.create('environment' => [{ 'variable' => 'foo', 'value' => 'bar' }])
    end

    let(:other_template) do
      JobTemplate.create('environment' => [{ 'variable' => 'foo', 'value' => 'baz' },
                                           { 'variable' => 'foo2', 'value' => 'quux' }])
    end

    it 'replaces existing environment variables with those in the other template' do
      job_template.override(other_template)
      expect(job_template.environment).to include('variable' => 'foo', 'value' => 'baz')
    end

    it 'adds new environment variables from the other template to the existing template' do
      job_template.override(other_template)
      expect(job_template.environment).to include('variable' => 'foo2', 'value' => 'quux')
    end
  end

end
