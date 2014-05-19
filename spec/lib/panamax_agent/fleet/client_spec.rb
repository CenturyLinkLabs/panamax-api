require 'spec_helper'

require 'panamax_agent/fleet/service_definition'

describe PanamaxAgent::Fleet::Client do

  describe '#submit' do

    let(:service_def) { PanamaxAgent::Fleet::ServiceDefinition.new('foo.service') }

    before do
      subject.stub(:create_unit).and_return(nil)
      subject.stub(:create_job).and_return(nil)
    end

    it 'invokes #create_payload' do
      expect(subject).to receive(:create_unit)
        .with(service_def.sha1, service_def.unit_def)

      subject.submit(service_def)
    end

    it 'invokes #create_job' do
      expect(subject).to receive(:create_job)
        .with(service_def.name, service_def.job_def)

      subject.submit(service_def)
    end
  end

  describe '#start' do
    let(:service_name) { 'foo.service' }

    before do
      subject.stub(:update_job_target_state)
    end

    it 'invokes #update_job_target_state' do
      expect(subject).to receive(:update_job_target_state)
        .with(service_name, :launched)

      subject.start(service_name)
    end
  end

  describe '#stop' do
    let(:service_name) { 'foo.service' }

    before do
      subject.stub(:update_job_target_state)
    end

    it 'invokes #update_job_target_state' do
      expect(subject).to receive(:update_job_target_state)
                         .with(service_name, :loaded)

      subject.stop(service_name)
    end

  end

  describe '#unload' do
    let(:service_name) { 'foo.service' }

    before do
      subject.stub(:update_job_target_state)
    end

    it 'invokes #update_job_target_state' do
      expect(subject).to receive(:update_job_target_state)
                         .with(service_name, :inactive)

      subject.unload(service_name)
    end

  end

  describe 'destroy' do
    let(:service_name) { 'foo.service' }

    before do
      subject.stub(:delete_job).and_return(nil)
    end

    it 'invokes #delete_job' do

      expect(subject).to receive(:delete_job)
                         .with(service_name)
                         .and_return(nil)

      subject.destroy(service_name)
    end

  end
end
