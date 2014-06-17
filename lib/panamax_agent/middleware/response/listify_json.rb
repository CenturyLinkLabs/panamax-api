require 'faraday'
require 'json'

module PanamaxAgent
  module Response

    class ListifyJson < Faraday::Response::Middleware

      def on_complete(env)
        body = env[:body]

        return if valid_json?(body)

        body = body.chomp.gsub("\n", ',')
        env[:body] = "[#{body}]"
      end

      private

      def valid_json?(string)
        JSON.parse(string)
        true
      rescue StandardError
        false
      end
    end

    Faraday.register_middleware :response, listify_json: -> { ListifyJson }
  end
end
