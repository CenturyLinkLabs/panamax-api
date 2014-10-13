require 'panamax_agent/client'
require 'panamax_agent/registry/client/repositories'
require 'panamax_agent/registry/client/search'

module PanamaxAgent
  module Registry
    class Client < PanamaxAgent::Client

      def initialize(options={})
        options = default_options.merge(options)
        super
        @base_path = registry_api_version
      end

      include PanamaxAgent::Registry::Connection
      include PanamaxAgent::Registry::Client::Repositories
      include PanamaxAgent::Registry::Client::Search

      protected

      def default_options
        {
          read_timeout: 15
        }
      end

      def resource_path(resource, *parts)
        parts.unshift(resource).unshift(@base_path).join('/')
      end
    end
  end
end
