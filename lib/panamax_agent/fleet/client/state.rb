require 'panamax_agent/client'

module PanamaxAgent
  module Fleet
    class Client < PanamaxAgent::Client
      module State

        STATE_RESOURCE = 'state'

        def list_states
          opts = { consistent: true, recursive: true, sorted: false }
          get(state_path, opts)
        end

        def get_state(service_name)
          opts = { consistent: true, recursive: true, sorted: false }
          get(state_path(service_name), opts)
        end

        private

        def state_path(*parts)
          resource_path(STATE_RESOURCE, *parts)
        end

      end
    end
  end
end

