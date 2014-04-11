module PanamaxAgent
  module Journal
    class Client < PanamaxAgent::Client
      module Fields

        FIELDS_RESOURCE = 'fields'
        VALID_FIELDS = [
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

        def get_values_by_field(field)
          if valid?(field)
            opts = {}
            get(fields_path(field),
                opts,
                headers={ accept: "#{@data_format}"})
          end
        end

        private

        def fields_path(*parts)
          resource_path(FIELDS_RESOURCE, *parts)
        end

        def valid?(field)
          VALID_FIELDS.include?(field)
        end

      end
    end
  end
end
