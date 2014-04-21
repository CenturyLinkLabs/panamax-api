require 'spec_helper'

VALID_FIELDS = [
    'PRIORITY',          # [0-6]
    'MESSAGE',
    'MESSAGE_ID',
    'ERRNO',             # low-level Unix error number
    'SYSLOG_IDENTIFIER',
    '_PID',              # process id for service
    '_SYSTEMD_UNIT',     # by service_name.service
    '_SYSTEMD_CGROUP',   # the cgroup for the service '/system.slice/update-engine.service'
    '_MACHINE_ID',
    '_HOSTNAME',
    '_TRANSPORT'         # ['driver', 'syslog', 'journal', 'stdout', 'kernel']
]

describe PanamaxAgent::Journal::Client::Fields do

  subject { PanamaxAgent::Journal::Client.new }

  let(:response) { double(:response) }

  before do
    subject.stub(get: response)
  end

  describe '#get_values_by_field' do

    VALID_FIELDS.each do |field|
      opts = {}
      it "GETs the values for the field - #{field}" do
        headers = { accept: 'application/json'}
        expect(subject).to receive(:get)
                           .with("fields/#{field}", opts)
                           .and_return(response)

        subject.get_values_by_field(field)
      end
      it 'returns the values by field response' do
        expect(subject.get_values_by_field(field)).to eql(response)
      end

    end

  end
end
