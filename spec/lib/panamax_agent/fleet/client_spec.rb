require 'spec_helper'

require 'panamax_agent/fleet/service_definition'

describe PanamaxAgent::Fleet::Client do

  describe '#load' do

    let(:service_def) { PanamaxAgent::Fleet::ServiceDefinition.new('foo.service') }
    let(:fleet_state) do
      { 'node' => { 'value' => '{ "load_state": "loaded" }' } }
    end

    before do
      subject.stub(:create_unit).and_return(nil)
      subject.stub(:create_job).and_return(nil)
      subject.stub(:update_job_target_state).and_return(nil)
      subject.stub(:get_state).and_return(fleet_state)
    end

    it 'invokes #create_unit' do
      expect(subject).to receive(:create_unit)
        .with(service_def.sha1, service_def.unit_def)

      subject.load(service_def)
    end

    it 'invokes #create_job' do
      expect(subject).to receive(:create_job)
        .with(service_def.name, service_def.job_def)

      subject.load(service_def)
    end

    it 'invokes #update_job_target_state' do
      expect(subject).to receive(:update_job_target_state)
        .with(service_def.name, :loaded)

      subject.load(service_def)
    end

    it 'checks the job state' do
      expect(subject).to receive(:get_state).with(service_def.name)
      subject.load(service_def)
    end

    context 'when #create_unit raises PreconditionFailed' do

      before do
        subject.stub(:create_unit).and_raise(
          PanamaxAgent::PreconditionFailed.new('boom'))
      end

      it 'does not blow up' do
        expect { subject.load(service_def) }.to_not raise_error
      end
    end

    context 'when #create_unit raises something other than PreconditionFailed' do

      before do
        subject.stub(:create_unit).and_raise(PanamaxAgent::BadRequest.new('boom'))
      end

      it 'propagates the error' do
        expect { subject.load(service_def) }.to(raise_error(PanamaxAgent::BadRequest))
      end
    end

    context 'when #create_job raises PreconditionFailed' do

      before do
        subject.stub(:create_job).and_raise(
          PanamaxAgent::PreconditionFailed.new('boom'))
      end

      it 'does not blow up' do
        expect { subject.load(service_def) }.to_not raise_error
      end
    end

    context 'when #create_job raises something other than PreconditionFailed' do

      before do
        subject.stub(:create_job).and_raise(PanamaxAgent::BadRequest.new('boom'))
      end

      it 'propagates the error' do
        expect { subject.load(service_def) }.to(raise_error(PanamaxAgent::BadRequest))
      end
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

    let(:fleet_state) do
      { 'node' => { 'value' => '{ "load_state": "loaded" }' } }
    end

    before do
      subject.stub(:update_job_target_state)
      subject.stub(:get_state).and_return(fleet_state)
    end

    it 'invokes #update_job_target_state' do
      expect(subject).to receive(:update_job_target_state)
                         .with(service_name, :loaded)

      subject.stop(service_name)
    end

    it 'checks the job state' do
      expect(subject).to receive(:get_state).with(service_name)
      subject.stop(service_name)
    end
  end

  describe '#unload' do
    let(:service_name) { 'foo.service' }

    let(:fleet_state) do
      { 'node' => { 'value' => '{ "load_state": "not-found" }' } }
    end

    before do
      subject.stub(:update_job_target_state)
      subject.stub(:get_state).and_return(fleet_state)
    end

    it 'invokes #update_job_target_state' do
      expect(subject).to receive(:update_job_target_state)
                         .with(service_name, :inactive)

      subject.unload(service_name)
    end

    it 'checks the job state' do
      expect(subject).to receive(:get_state).with(service_name)
      subject.unload(service_name)
    end

    context 'when the unload state cannot be achieved' do

      before do
        subject.stub(:get_state).and_raise(PanamaxAgent::NotFound, 'boom')
        subject.stub(:sleep)
      end

      it 're-checks the state 10 times' do
        expect(subject).to receive(:get_state).exactly(10).times
        subject.unload(service_name) rescue nil
      end

      it 'raises an error' do
        expect do
          subject.unload(service_name)
        end.to raise_error(PanamaxAgent::Error)
      end

    end
  end

  describe '#destroy' do
    let(:service_name) { 'foo.service' }

    before do
      subject.stub(:delete_job).and_return(nil)
      subject.stub(:get_state).and_raise(PanamaxAgent::NotFound, 'boom')
    end

    it 'invokes #delete_job' do

      expect(subject).to receive(:delete_job)
                         .with(service_name)
                         .and_return(nil)

      subject.destroy(service_name)
    end

    it 'checks the job state' do
      expect(subject).to receive(:get_state).with(service_name)
      subject.destroy(service_name)
    end
  end

  describe '#states' do

    let(:service_name) { 'foo.service' }

    let(:fleet_state) do
      { 'node' => { 'value' => '{"load": "loaded", "run": "running"}' } }
    end

    before do
      subject.stub(:get_state).and_return(fleet_state)
    end

    it 'retrieves service state from the fleet client' do
      expect(subject).to receive(:get_state).with(service_name)
      subject.states(service_name)
    end

    it 'returns the state hash w/ normalized keys' do
      expect(subject.states(service_name)).to eq(load: 'loaded', run: 'running')
    end
  end
end
