module AppJournal
  extend ActiveSupport::Concern

  def journal(cursor=nil)
    service_names = self.services.map(&:unit_name)
    journal_client.list_journal_entries(service_names, cursor)
  end

  private

  def journal_client
    PanamaxAgent.journal_client
  end
end
