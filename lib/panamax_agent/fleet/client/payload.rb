require 'panamax_agent/client'

module PanamaxAgent
  module Fleet
    class Client < PanamaxAgent::Client
      module Payload

        PAYLOAD_RESOURCE = 'payload'

        def list_payloads
          opts = { consistent: true, recursive: true, sorted: true }
          get(payload_path, opts)
        end

        def get_payload(service_name)
          opts = { consistent: true, recursive: true, sorted: false }
          get(payload_path(service_name), opts)
        end

        def create_payload(service_def)
          opts = {
            querystring: { 'prevExist' => false },
            body: { value: service_def.to_json }
          }
          put(payload_path(service_def.name),
              opts,
              headers={},
              request_type=:url_encoded)
        end

        def delete_payload(service_name)
          opts = { dir: false, recursive: false }
          delete(payload_path(service_name), opts)
        end

        private

        def payload_path(*parts)
          resource_path(PAYLOAD_RESOURCE, *parts)
        end

      end
    end
  end
end
