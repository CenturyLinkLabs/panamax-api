require 'panamax_agent/client'
require 'panamax_agent/journal/client/machine'
require 'panamax_agent/journal/client/entries'
require 'panamax_agent/journal/client/fields'

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
          '_SYSTEMD_UNIT',     # by service_name.service
          '_SYSTEMD_CGROUP',   # the cgroup for the service '/system.slice/update-engine.service'
          '_MACHINE_ID',
          '_HOSTNAME',
          '_TRANSPORT'         # ['driver', 'syslog', 'journal', 'stdout', 'kernel']
      ]

      def initialize(options={})
        super
        @url = self.journal_api_url
      end

      include PanamaxAgent::Journal::Client::Machine
      include PanamaxAgent::Journal::Client::Entries
      include PanamaxAgent::Journal::Client::Fields
    end
  end
end
