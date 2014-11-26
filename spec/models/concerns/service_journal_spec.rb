require 'spec_helper'

describe ServiceJournal do

  subject do
    Class.new do
      include ServiceJournal

      def unit_name
        'dummy.service'
      end
    end.new
  end

  describe '#journal' do

    let(:journal_client) { double(:dummy_journal_client) }
    let(:journal) { hash_from_fixture('journal') }

    before do
      allow(journal_client).to receive(:list_journal_entries).and_return(journal)
      allow(PanamaxAgent).to receive(:journal_client).and_return(journal_client)
    end

    it 'invokes get_entries_by_fields on journal client' do
      expect(journal_client).to receive(:list_journal_entries)
        .with(subject.unit_name, nil)
      subject.journal
    end

    it 'returns the service journal' do
      expect(subject.journal).to eq journal
    end

    context 'when a cursor is supplied' do
      let(:cursor) { 'c2' }

      it 'passes the cursor to the journal_client' do

        expect(journal_client).to receive(:list_journal_entries)
          .with(subject.unit_name, cursor)
        subject.journal(cursor)
      end
    end
  end
end
