require 'faraday'
require 'panamax_agent/middleware/response/raise_error'

module PanamaxAgent
  module Mailchimp
    module Connection

      def connection
        Faraday.new(connection_options) do |faraday|
          faraday.request :url_encoded
          faraday.response :raise_error
          faraday.adapter adapter
        end
      end

      private

      def connection_options
        {
          url: mailchimp_api_url,
          proxy: proxy
        }
      end

    end
  end
end
