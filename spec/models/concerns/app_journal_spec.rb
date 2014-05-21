require 'spec_helper'

describe AppJournal do

  subject do
    Class.new do
      include AppJournal

      def services
        [
          Service.new(name: 's1'),
          Service.new(name: 's2')
        ]
      end
    end.new
  end

  describe '#journal' do

    let(:journal) { hash_from_fixture('journal') }
    let(:journal_client) do
      # Note that the journal_client has already been stubbed in the
      # spec helper. Retrieving here just so we can test expectations.
      PanamaxAgent.journal_client
    end

    it 'invokes get_entries_by_fields on journal client' do
      service_names = subject.services.map(&:unit_name)
      expect(journal_client).to receive(:list_journal_entries)
        .with(service_names, nil)
      subject.journal
    end

    it 'returns the service journal' do
      expect(subject.journal).to eq journal
    end

    context 'when a cursor is supplied' do
      let(:cursor) { 'c2' }

      it 'passes the cursor to the journal_client' do
        service_names = subject.services.map(&:unit_name)
        expect(journal_client).to receive(:list_journal_entries)
          .with(service_names, cursor)
        subject.journal(cursor)
      end
    end
  end
end
