require 'faraday'
require 'panamax_agent/middleware/response/raise_error'

module PanamaxAgent
  module Panamax
    module Connection

      def connection
        Faraday.new(connection_options) do |faraday|
          faraday.request :url_encoded
          faraday.response :json
          faraday.response :raise_error
          faraday.adapter adapter
        end
      end

      private

      def connection_options
        {
          url: etcd_api_url,
          ssl: ssl_options,
          proxy: proxy
        }
      end

    end
  end
end
