require 'panamax_agent/client'
require 'panamax_agent/registry/client/repositories'

module PanamaxAgent
  module Registry
    class Client < PanamaxAgent::Client
      include PanamaxAgent::Registry::Connection
      include PanamaxAgent::Registry::Client::Repositories
    end
  end
end
