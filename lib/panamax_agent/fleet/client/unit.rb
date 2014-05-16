require 'panamax_agent/client'

module PanamaxAgent
  module Fleet
    class Client < PanamaxAgent::Client
      module Unit

        UNIT_RESOURCE = 'unit'

        def create_unit(unit_sha1, unit_def)
          opts = {
            querystring: { 'prevExist' => false },
            body: { value: unit_def.to_json }
          }
          put(unit_path(unit_sha1), opts)
        end

        def delete_unit(unit_sha1)
          opts = { dir: false, recursive: false }
          delete(unit_path(unit_sha1), opts)
        end

        private

        def unit_path(*parts)
          resource_path(UNIT_RESOURCE, *parts)
        end

      end
    end
  end
end
