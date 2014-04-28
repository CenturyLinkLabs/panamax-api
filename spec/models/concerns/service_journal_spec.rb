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
      journal_client.stub(get_entries_by_fields: journal)
      PanamaxAgent.stub(journal_client: journal_client)
    end

    it 'invokes get_entries_by_fields on journal client' do
      expect(journal_client).to receive(:get_entries_by_fields)
        .with({ '_SYSTEMD_UNIT' => subject.unit_name })
      subject.journal
    end

    it 'returns the service journal' do
      expect(subject.journal).to eq journal
    end
  end
end
