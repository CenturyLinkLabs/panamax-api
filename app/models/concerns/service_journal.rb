module ServiceJournal
  extend ActiveSupport::Concern

  def journal(cursor=nil)
    journal_client.list_journal_entries(unit_name, cursor)
  end

  private

  def journal_client
    PanamaxAgent.journal_client
  end
end
