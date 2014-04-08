require 'faraday'

module PanamaxAgent
  module Connection

    def connection(request_type=:json)
      Faraday.new(options) do |faraday|
        faraday.request request_type
        faraday.response :json
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
