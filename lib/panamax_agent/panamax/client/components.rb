module PanamaxAgent
  module Panamax
    class Client < PanamaxAgent::Client
      module Components

        PANAMAX_COMPONENTS = %w(panamax-ui panamax-api)

        def list_components
          components = [
            {
              'panamax-agent' => [
                {
                  'versions' => { PanamaxAgent::VERSION => '' }
                }
              ]
            }
          ]

          PANAMAX_COMPONENTS.each do |component|
            comp_metadata = []
            comp_metadata << {
              'versions' => registry_client.list_repository_tags(component)
            }
            components << { component => comp_metadata }
          end
          components
        end

        def get_component(component)
          comp = []
          if component == 'panamax-agent'
            comp_versions = { PanamaxAgent::VERSION => '' }
            comp << { 'versions' => comp_versions }
          else
            if PANAMAX_COMPONENTS.include?(component)
              comp_versions = registry_client.list_repository_tags(component)
              comp << { 'versions' => comp_versions }
            end
          end
          comp
        end

      end
    end
  end
end
