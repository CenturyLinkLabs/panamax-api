require 'panamax_agent/client'
require 'panamax_agent/registry/client/repositories'

module PanamaxAgent
  module Registry
    class Client < PanamaxAgent::Client

      def initialize(options={})
        super
        @url = self.registry_api_url
        @api_version = self.registry_api_version
      end

      include PanamaxAgent::Registry::Client::Repositories
    end
  end
end
