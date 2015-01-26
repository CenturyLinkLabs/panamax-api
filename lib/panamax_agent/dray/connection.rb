require 'faraday'

module PanamaxAgent
  module Dray
    module Connection

      def connection
        Faraday.new(connection_options) do |faraday|
          faraday.request :json
          faraday.response :json
          faraday.adapter adapter
        end
      end

      private

      def connection_options
        {
          url: dray_api_url,
          ssl: ssl_options,
          proxy: proxy
        }
      end

    end
  end
end
