require 'panamax_agent/client'
# require 'panamax_agent/dray/client/jobs'

module PanamaxAgent
  module Dray
    class Client < PanamaxAgent::Client

      def initialize(options={})
        options = default_options.merge(options)
        super
        @base_path = ''
        # @base_path = dray_api_version
      end

      include PanamaxAgent::Dray::Connection
      include PanamaxAgent::Dray::Client::Jobs

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
