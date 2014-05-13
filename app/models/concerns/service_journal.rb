module ServiceJournal
  extend ActiveSupport::Concern

  def journal(cursor=nil)
    journal_client.get_entries_by_fields(
      { '_SYSTEMD_UNIT' => unit_name },
      cursor
    )
  end

  private

  def journal_client
    PanamaxAgent.journal_client
  end
end
