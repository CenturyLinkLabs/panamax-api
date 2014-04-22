require 'panamax_agent/client'
require 'panamax_agent/registry/client/repositories'

module PanamaxAgent
  module Registry
    class Client < PanamaxAgent::Client

      def initialize(options={})
        super
        @base_path = registry_api_version
      end

      include PanamaxAgent::Registry::Connection
      include PanamaxAgent::Registry::Client::Repositories

      protected

      def resource_path(resource, *parts)
        parts.unshift(resource).unshift(@base_path).join('/')
      end
    end
  end
end
