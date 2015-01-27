require 'spec_helper'

describe JobBuilder do

  describe '.create' do

    before do
      allow(JobBuilder::FromTemplate).to receive(:create_job).and_return(Job.new)
    end

    it 'builds a Job' do
      t = described_class.create({})
      expect(t).to be_a Job
    end

  end

end
