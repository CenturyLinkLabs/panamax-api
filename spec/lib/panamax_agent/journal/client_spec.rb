require 'spec_helper'

describe PanamaxAgent::Journal::Client do

  subject { PanamaxAgent::Journal::Client.new }

  describe '#list_journal_entries' do

    let(:journal_lines) do
      [
        {
          'MESSAGE' => 'foo is starting',
          'UNIT' => 'foo.service'
        },
        {
          'MESSAGE' => 'bar is starting',
          'UNIT' => 'bar.service'
        },
        {
          'MESSAGE' => 'foo is running',
          '_SYSTEMD_UNIT' => 'foo.service'
        }
      ]
    end

    before do
      subject.stub(:get_entries_by_fields).and_return(journal_lines)
    end

    it 'invokes the get_entries_by_fields method' do
      services = 'foo'
      cursor = 'bar'
      expect(subject).to receive(:get_entries_by_fields).with({}, cursor)
      subject.list_journal_entries(services, cursor)
    end

    context 'when a single service argument is provided' do

      let(:services) { 'foo.service' }

      it 'returns only the journal lines for the service' do
        response = subject.list_journal_entries(services)

        expect(response).to have(2).items
        expect(response).to include(journal_lines[0])
        expect(response).to include(journal_lines[2])
      end
    end

    context 'when multiple service arguments are provided' do

      let(:services) { ['foo.service', 'bar.service'] }

      it 'returns the journal lines for all the specified services' do
        response = subject.list_journal_entries(services)

        expect(response).to have(3).items
        expect(response).to include(*journal_lines)
      end
    end
  end
end
