require 'spec_helper'

describe PanamaxAgent::Fleet::Client::Job do

  subject { PanamaxAgent::Fleet::Client.new }

  let(:response) { double(:response) }

  describe '#list_jobs' do

    before do
      subject.stub(get: response)
    end

    it 'GETs the Fleet job key' do
      opts = { consistent: true, recursive: true, sorted: true }
      expect(subject).to receive(:get)
        .with('v2/keys/_coreos.com/fleet/job', opts)
        .and_return(response)

      subject.list_jobs
    end

    it 'returns the job response' do
      expect(subject.list_jobs).to eql(response)
    end
  end

  describe '#get_job' do

    let(:service_name) { 'foo.service' }

    before do
      subject.stub(get: response)
    end

    it 'GETs the named Fleet job key' do
      opts = { consistent: true, recursive: true, sorted: false }
      expect(subject).to receive(:get)
        .with("v2/keys/_coreos.com/fleet/job/#{service_name}/object", opts)
        .and_return(response)

      subject.get_job(service_name)
    end

    it 'returns the job response' do
      expect(subject.get_job(service_name)).to eql(response)
    end
  end

  describe '#create_job' do

    let(:service_name) { 'foo.service' }
    let(:service_def) { { name: service_name } }

    before do
      subject.stub(put: response)
    end

    it 'PUTs the service def to the Fleet job key' do
      opts = {
        querystring: { 'prevExist' => false },
        body: { value: service_def.to_json }
      }

      expect(subject).to receive(:put)
        .with("v2/keys/_coreos.com/fleet/job/#{service_name}/object", opts)
        .and_return(response)

      subject.create_job(service_name, service_def)
    end

    it 'returns the job response' do
      expect(subject.create_job(service_name, service_def)).to eql(response)
    end
  end

  describe '#delete_job' do

    let(:service_name) { 'foo.service' }

    before do
      subject.stub(delete: response)
    end

    it 'DELETEs the named Fleet job key' do
      opts = { dir: false, recursive: true }
      expect(subject).to receive(:delete)
        .with("v2/keys/_coreos.com/fleet/job/#{service_name}", opts)
        .and_return(response)

      subject.delete_job(service_name)
    end

    it 'returns the job response' do
      expect(subject.delete_job(service_name)).to eql(response)
    end
  end

  describe '#update_job_target_state' do

    let(:service_name) { 'foo.service' }
    let(:state) { :foobared }

    before do
      subject.stub(put: response)
    end

    it 'PUTs the state to the Fleet job state key' do
      opts = { value: state }

      expect(subject).to receive(:put)
        .with("v2/keys/_coreos.com/fleet/job/#{service_name}/target-state", opts)
        .and_return(response)

      subject.update_job_target_state(service_name, state)
    end

    it 'returns the job response' do
      expect(subject.update_job_target_state(service_name, state)).to eql(response)
    end
  end
end
