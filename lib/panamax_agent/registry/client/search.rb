module PanamaxAgent
  module Registry
    class Client < PanamaxAgent::Client
      module Search

        SEARCH_RESOURCE = 'search'

        def search(keyword)
          get(resource_path(SEARCH_RESOURCE), q: keyword)
        end
      end
    end
  end
end
