module PanamaxAgent
  module Journal
    class Client < PanamaxAgent::Client
      module Fields

        FIELDS_RESOURCE = 'fields'

        def get_values_by_field(field)
          if valid?(field)
            opts = {}
            get(fields_path(field), opts)
          end
        end

        private

        def fields_path(*parts)
          resource_path(FIELDS_RESOURCE, *parts)
        end

        def valid?(field)
          VALID_JOURNAL_FIELDS.include?(field)
        end

      end
    end
  end
end
