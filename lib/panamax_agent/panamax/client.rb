require 'panamax_agent/client'
require 'panamax_agent/panamax/client/components'
require 'panamax_agent/panamax/client/host_metrics'

module PanamaxAgent
  module Panamax
    class Client < PanamaxAgent::Client

      PANAMAX_METRICS_PATH = '/keys/_panamax'

      attr_reader :registry_client

      def initialize(options={})
        super
        @registry_client = PanamaxAgent::Registry::Client.new(
          registry_api_url: pmx_registry_api_url,
          registry_api_version: pmx_registry_api_version)

        @metrics_path = etcd_api_version + PANAMAX_METRICS_PATH
      end

      include PanamaxAgent::Panamax::Connection
      include PanamaxAgent::Panamax::Client::Components
      include PanamaxAgent::Panamax::Client::HostMetrics

      protected

      def resource_path(resource, *parts)
        parts.unshift(resource).unshift(@metrics_path).join('/')
      end

    end
  end
end
