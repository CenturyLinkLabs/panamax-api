require 'spec_helper'

describe PanamaxAgent::Journal::Client::Entries do

  subject { PanamaxAgent::Journal::Client.new }

  let(:response) { double(:response) }

  let(:opts) do
    {
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
      'UNIT' => 'update_engine.service',
      '_TRANSPORT' => 'stdout'
    }
  end

  before do
    allow(subject).to receive(:get).and_return(response)
  end

  describe '#get_entries_by_fields' do

    it 'returns the response' do
      expect(subject.get_entries_by_fields(opts)).to eql response
    end

    context 'when only valid field pairs passed' do

      it 'all fields are passed to API' do
        expect(subject).to(
          receive(:get)
            .with('entries', hash_including(opts), {})
            .and_return(response)
        )

        subject.get_entries_by_fields(opts)
      end
    end

    context 'when invalid field pairs are passed' do

      let(:opts_with_invalid_keys) do
        opts.merge('foo' => 'bar')
      end

      it 'does not pass invalid fields to API' do
        expect(subject).to(
          receive(:get)
            .with('entries', hash_not_including('foo' => 'bar'), {})
            .and_return(response)
        )

        subject.get_entries_by_fields(opts_with_invalid_keys)
      end
    end

    context 'when cursor is provided' do

      let(:cursor) { 'cursor1' }

      it 'passes cursor in range header to API' do
        expect(subject).to(
          receive(:get)
            .with('entries', hash_including(opts), 'Range' => "entries=#{cursor}")
            .and_return(response)
        )

        subject.get_entries_by_fields(opts, cursor)
      end
    end

    context 'when boot offset is defaulted' do

      it 'passes boot=0 to API' do
        expect(subject).to(
          receive(:get)
            .with('entries', hash_including('boot' => 0), {})
            .and_return(response)
        )

        subject.get_entries_by_fields(opts)
      end
    end

    context 'when boot offset is passed explicitly' do

      it 'passes boot param to API' do
        expect(subject).to(
          receive(:get)
            .with('entries', hash_including('boot' => 1), {})
            .and_return(response)
        )

        subject.get_entries_by_fields(opts, nil, 1)
      end
    end

    context 'when boot offset is set to 99999' do

      it 'it does not pass boot parameter to API' do
        expect(subject).to(
          receive(:get)
            .with('entries', hash_not_including('boot' => 99_999), {})
            .and_return(response)
        )

        subject.get_entries_by_fields(opts, nil, 99_999)
      end
    end

  end
end
