require 'panamax_agent/client'
# require 'panamax_agent/stevedore/client/jobs'

module PanamaxAgent
  module Stevedore
    class Client < PanamaxAgent::Client

      def initialize(options={})
        options = default_options.merge(options)
        super
        @base_path = ''
        # @base_path = stevedore_api_version
      end

      include PanamaxAgent::Stevedore::Connection
      include PanamaxAgent::Stevedore::Client::Jobs

      protected

      def default_options
        {
          read_timeout: 30,
          open_timeout: 10
        }
      end

      def resource_path(resource, *parts)
        parts.unshift(resource).unshift(@base_path).join('/')
      end
    end
  end
end
