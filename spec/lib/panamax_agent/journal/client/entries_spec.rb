require 'spec_helper'

VALID_FIELDPAIRS_FOR_ENTRIES = {
    'PRIORITY' => 6,
    'MESSAGE' => '',
    'MESSAGE_ID' => '',
    'ERRNO' => 19,
    '_PID' => 3089,
    'SYSLOG_IDENTIFIER' => 'update_engine',
    '_SYSTEMD_UNIT' => 'update_engine.service',
    '_SYSTEMD_CGROUP' => '/system.slice/update-engine.service',
    '_MACHINE_ID' => 'ad688e42fbbb4d6b8a8f804147245d7b',
    '_HOSTNAME' => 'coreos-alpha',
    '_TRANSPORT' => 'stdout'
}

describe PanamaxAgent::Journal::Client::Entries do

  subject { PanamaxAgent::Journal::Client.new }

  let(:response) { double(:response) }

  before do
    subject.stub(get: response)
  end

  describe '#get_entries_by_fields - current boot with single key' do
    opts = {'boot' => 0}
    VALID_FIELDPAIRS_FOR_ENTRIES.each do |key, value|
      opts[key] = value
      it "GETs the entries resource for key - #{key}=#{value}" do
        expect(subject).to receive(:get)
                           .with("entries", opts)
                           .and_return(response)

        subject.get_entries_by_fields(opts)
      end
      it 'returns the entries by key response' do
        expect(subject.get_entries_by_fields(opts)).to eql(response)
      end

    end
  end

  describe '#get_entries_by_fields - all boots with single key' do
    opts = {'boot' => 99999}
    VALID_FIELDPAIRS_FOR_ENTRIES.each do |key, value|
      opts[key] = value
      it "GETs the entries resource for key - #{key}=#{value}" do
        expect(subject).to receive(:get)
                           .with("entries", opts)
                           .and_return(response)

        subject.get_entries_by_fields(opts, 99999)
      end
      it 'returns the entries by key response' do
        expect(subject.get_entries_by_fields(opts, 99999)).to eql(response)
      end

    end
  end

  describe '#get_entries_by_fields - current boot with multiple keys' do
    opts = {'boot' => 0}.merge!(VALID_FIELDPAIRS_FOR_ENTRIES)

    it 'GETs the entries resource for multiple keys' do
      expect(subject).to receive(:get)
                         .with("entries", opts)
                         .and_return(response)

      subject.get_entries_by_fields(opts)
    end
    it 'returns the entries by multiple keys response' do
      expect(subject.get_entries_by_fields(opts)).to eql(response)
    end
  end

  describe '#get_entries_by_fields - all boots with multiple keys' do
    opts = {'boot' => 99999}.merge!(VALID_FIELDPAIRS_FOR_ENTRIES)

    it 'GETs the entries resource for multiple keys' do
      expect(subject).to receive(:get)
                         .with("entries", opts)
                         .and_return(response)

      subject.get_entries_by_fields(opts, 99999)
    end
    it 'returns the entries by multiple keys response' do
      expect(subject.get_entries_by_fields(opts, 99999)).to eql(response)
    end
  end

end
