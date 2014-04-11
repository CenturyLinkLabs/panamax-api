module PanamaxAgent
  module Journal
    class Client < PanamaxAgent::Client
      module Machine

        MACHINE_RESOURCE = 'machine'

        def get_machine
          get(machine_path)
        end

        private

        def machine_path(*parts)
          resource_path(MACHINE_RESOURCE, *parts)
        end

      end
    end
  end
end
