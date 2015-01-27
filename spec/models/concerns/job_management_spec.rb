require 'spec_helper'

describe JobManagement do
  subject do
    Class.new do
      include JobManagement
      attr_reader :environment
    end.new
  end

  let(:get_job_response) { { 'id' => '1234', 'stepsCompleted' => '1', 'status' => 'running' } }

  let(:create_response) { { 'id' => '1234' } }

  let(:fake_dray_client) do
    double(:fake_dray_client,
           get_job: get_job_response,
           create_job: create_response,
           delete_job: true
    )
  end

  before do
    allow(PanamaxAgent::Dray::Client).to receive(:new).and_return(fake_dray_client)
  end

  describe '#status' do
    before do
      allow(subject).to receive(:key).and_return('1234')
    end

    it 'returns the status of the remote job' do
      expect(subject.status).to eq('running')
    end

    context 'when the remote job has no status' do
      before do
        allow(fake_dray_client).to receive(:get_job).and_return({})
      end

      it 'returns nil' do
        expect(subject.status).to be_nil
      end
    end
  end

  describe '#completed_steps' do
    before do
      allow(subject).to receive(:key).and_return('1234')
    end

    it 'returns the completed steps of the remote job' do
      expect(subject.completed_steps).to eq(1)
    end

    context 'when the remote job has no completedSteps' do
      before do
        allow(fake_dray_client).to receive(:get_job).and_return({})
      end

      it 'returns nil' do
        expect(subject.completed_steps).to be_nil
      end
    end

  end

  describe '#start_job' do

    before do
      allow(subject).to receive(:steps).and_return([])
      allow(subject).to receive(:job_template).and_return(double(name: 'the template'))
    end

    it 'creates the job' do
      expect(subject).to receive(:update).with(key: '1234')
      subject.start_job
    end

    context 'when creation fails' do
      before do
        allow(fake_dray_client).to receive(:create_job).and_raise('boom')
      end

      it 'raises the error and does not call update on the model' do
        expect do
          subject.start_job
        end.to raise_error('boom')
        expect(subject).not_to receive(:update)
      end

    end
  end

  describe '#destroy_job' do
    before do
      allow(subject).to receive(:key).and_return('1234')
    end

    it 'destroys the job' do
      expect(subject).to receive(:destroy)
      subject.destroy_job
    end

    context 'when the client cannot delete the job' do
      before do
        allow(fake_dray_client).to receive(:delete_job).and_return(nil)
      end

      it 'should not call destroy on the model' do
        expect(subject).not_to receive(:destroy)
        subject.destroy_job
      end
    end
  end

  context 'when attempts to retrieve the remote data fail' do
    before do
      allow(fake_dray_client).to receive(:get_job).and_raise('boom')
    end

    describe '#get_state' do
      it 'returns an empty hash' do
        expect(subject.send(:get_state)).to eq({})
      end
    end
  end

  describe '#log' do
    before do
      allow(subject).to receive(:key).and_return('1234')
    end

    it 'gets the job log from dray' do
      expect(fake_dray_client).to receive(:get_job_log).with(subject.key)
      subject.log
    end
  end
end
