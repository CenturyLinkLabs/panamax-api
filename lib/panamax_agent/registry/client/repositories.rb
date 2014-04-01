module PanamaxAgent
  module Registry
    class Client < PanamaxAgent::Client
      module Repositories

        REPOSITORIES_RESOURCE = 'repositories'

        def list_repository_tags(repository)
          get(repositories_path(repository, 'tags'))
        end

        def get_repository_tag(repository, tag)
          get(repositories_path(repository, 'tags', tag))
        end

        private

        def repositories_path(*parts)
          resource_path(REPOSITORIES_RESOURCE, *parts)
        end

      end
    end
  end
end
