require 'panamax_agent/client'
require 'panamax_agent/journal/client/machine'
require 'panamax_agent/journal/client/entries'
require 'panamax_agent/journal/client/fields'

module PanamaxAgent
  module Journal
    class Client < PanamaxAgent::Client

      JOURNAL_DATA_FORMAT = {
          :text     => 'text/plain',
          :json     => 'application/json',
          :json_sse => 'application/event-stream',
          :export   => 'application/vnd.fdo.journal'
      }

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
        @data_format = JOURNAL_DATA_FORMAT[self.journal_data_format]
      end

      def data_format=(new_format)
        if JOURNAL_DATA_FORMAT.include?(new_format)
          @data_format = JOURNAL_DATA_FORMAT[new_format]
        end
      end

      include PanamaxAgent::Journal::Client::Machine
      include PanamaxAgent::Journal::Client::Entries
      include PanamaxAgent::Journal::Client::Fields
    end
  end
end
