require 'faraday'
require 'panamax_agent/middleware/response/raise_error'

module PanamaxAgent
  module Connection

    def connection(request_type=:json)
      Faraday.new(options) do |faraday|
        faraday.request request_type
        faraday.response :json
        faraday.response :raise_error
        faraday.adapter adapter
      end
    end

    private

    def options
      {
        url: [url, api_version].join('/'),
        ssl: ssl_options,
        proxy: proxy
      }
    end

  end
end
