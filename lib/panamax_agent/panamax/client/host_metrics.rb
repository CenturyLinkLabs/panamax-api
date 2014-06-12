require 'panamax_agent/error'

module PanamaxAgent
  module Panamax
    class Client < PanamaxAgent::Client
      module HostMetrics

        HOST_METRICS_RESOURCE = 'host/metrics'

        def list_host_metrics
          metrics = {}
          begin
            metrics_data = get_host_metrics
          rescue PanamaxAgent::NotFound
          end

          metrics = JSON.parse(metrics_data['node']['value']) if metrics_data

          { 'host_metrics' => metrics }
        end

        private

        def get_host_metrics
          get(host_metrics_path)
        end

        def host_metrics_path(*parts)
          resource_path(HOST_METRICS_RESOURCE, *parts)
        end
      end
    end
  end
end
