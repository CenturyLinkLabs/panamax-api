require 'panamax_agent/client'
require 'panamax_agent/journal/client/entries'

module PanamaxAgent
  module Journal
    class Client < PanamaxAgent::Client

      VALID_JOURNAL_FIELDS = [
        'PRIORITY',          # [0-6]
        'MESSAGE',
        'MESSAGE_ID',
        'ERRNO',             # low-level Unix error number
        'SYSLOG_IDENTIFIER',
        '_PID',              # process id for service
        '_SYSTEMD_UNIT',     # only journal logs by service_name.service
        '_SYSTEMD_CGROUP',   # the cgroup for the service '/system.slice/update-engine.service'
        '_MACHINE_ID',
        '_HOSTNAME',
        'UNIT',              # only systemd logs by service_name.service
        '_TRANSPORT'         # ['driver', 'syslog', 'journal', 'stdout', 'kernel']
      ]

      include PanamaxAgent::Journal::Connection
      include PanamaxAgent::Journal::Client::Entries

      def list_journal_entries(services, cursor=nil)
        services = [*services]

        # If there is no cursor supplied, never retrieve more than
        # 10,000 entries
        cursor = ':-10000:' if cursor.nil? || cursor.empty?

        journal_lines = get_entries_by_fields({}, cursor)

        journal_lines.select do |journal_line|
          services.include?(journal_line['UNIT']) ||
            services.include?(journal_line['_SYSTEMD_UNIT'])
        end
      end
    end
  end
end
