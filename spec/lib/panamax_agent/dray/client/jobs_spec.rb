require 'spec_helper'

describe PanamaxAgent::Dray::Client::Jobs do

  subject { PanamaxAgent::Dray::Client.new }

  let(:job_id) { '1234-1234-1234' }
  let(:response) { double(:response) }

  before do
    allow(subject).to receive(:get).and_return(response)
  end

  describe '#create_job' do
    let(:job_attrs) { { name: 'job' } }

    it 'POSTs the job steps' do
      expect(subject).to receive(:post).with('/jobs', job_attrs).and_return(response)
      subject.create_job(job_attrs)
    end

  end

  describe '#list_jobs' do

    it 'GETs the jobs' do
      expect(subject).to receive(:get).with('/jobs').and_return(response)
      subject.list_jobs
    end

  end

  describe '#get_job' do

    it 'GETs the job' do
      expect(subject).to receive(:get).with("/jobs/#{job_id}").and_return(response)
      subject.get_job(job_id)
    end

  end

  describe '#get_job_log' do

    it 'GETs the job log' do
      expect(subject).to receive(:get).with("/jobs/#{job_id}/log", index: 3).and_return(response)
      subject.get_job_log(job_id, index: 3)
    end

    describe '#delete_job' do

      it 'DELETEs the job' do
        expect(subject).to receive(:delete).with("/jobs/#{job_id}").and_return(response)
        subject.delete_job(job_id)
      end

    end

  end
end
