require 'faraday'

module PanamaxAgent
  module Connection

    def connection
      Faraday.new(options) do |faraday|
        faraday.request :json
        faraday.response :json
        faraday.adapter adapter

        faraday.headers = headers
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

    def headers
      {
        user_agent: user_agent,
        accept: 'application/json',
        content_type: 'application/json'
      }
    end

    def user_agent
      ua_chunks = []
      ua_chunks << "panamax_agent/#{PanamaxAgent::VERSION}"
      ua_chunks << "(#{RUBY_ENGINE}; #{RUBY_VERSION}p#{RUBY_PATCHLEVEL}; #{RUBY_PLATFORM})"
      ua_chunks << "faraday/#{Faraday::VERSION}"
      ua_chunks << "(#{adapter})"
      ua_chunks.join(' ')
    end
  end
end
