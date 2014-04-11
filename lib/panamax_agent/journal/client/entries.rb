module PanamaxAgent
  module Journal
    class Client < PanamaxAgent::Client
      module Entries

        ENTRIES_RESOURCE = 'entries'
        VALID_FIELDS_FOR_ENTRIES = [
          'boot',              # 0 - current boot, [-1,-2,...] - previous boots
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

        def get_entries_by_fields(fieldpairs={})
          opts = remove_invalid_fieldpairs(fieldpairs)

          get(entries_path,
              opts,
              headers={ accept: "#{@data_format}"})
        end

        private

        def entries_path(*parts)
          resource_path(ENTRIES_RESOURCE, *parts)
        end

        def remove_invalid_fieldpairs(fieldpairs)
          opts = {}
          fieldpairs.each do |key,value|
            key = key.upcase
            if VALID_FIELDS_FOR_ENTRIES.include?(key)
              opts.merge!({key => value})
            end
          end

        end
      end
    end
  end
end
