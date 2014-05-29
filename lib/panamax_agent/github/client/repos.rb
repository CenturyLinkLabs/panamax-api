module PanamaxAgent
  module Github
    class Client < PanamaxAgent::Client
      module Repos

        def list_repos
          github_client.repos
        end

        def get_repo(repo)
          github_client.repo(repo)
        end

      end
    end
  end
end
