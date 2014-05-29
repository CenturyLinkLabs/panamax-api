module PanamaxAgent
  module Journal
    class Client < PanamaxAgent::Client
      module Entries

        ENTRIES_RESOURCE = 'entries'

        ###
        # boot_offset : -1 - show entries from the boot before last
        #             : 0  - show entries from the current or the last boot
        #             : 1  - show entries from the first boot
        #             : 99999 - special value to show entries from all boots
        ###
        def get_entries_by_fields(fieldpairs={}, cursor=nil, boot_offset=0)
          headers = {}
          headers['Range'] = "entries=#{cursor}" if cursor

          opts = remove_invalid_fieldpairs(fieldpairs)
          opts['boot'] = boot_offset unless boot_offset == 99999

          get(entries_path, opts, headers)
        end

        private

        def entries_path(*parts)
          resource_path(ENTRIES_RESOURCE, *parts)
        end

        def remove_invalid_fieldpairs(fieldpairs)
          fieldpairs.each_with_object({}) do |(key, value), opts|
            next unless VALID_JOURNAL_FIELDS.include?(key)
            opts[key.upcase] = value
          end
        end

      end
    end
  end
end
