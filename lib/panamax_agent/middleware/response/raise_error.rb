require 'faraday'
require 'json'
require 'panamax_agent/error'

module PanamaxAgent
  module Response

    class RaiseError < Faraday::Response::Middleware

      def on_complete(env)
        status = env[:status].to_i
        return unless (400..600).include?(status)

        error = parse_error(env[:body])

        # Find the error class that matches the HTTP status code. Default to
        # Error if no matching class exists.
        class_name = PanamaxAgent::Error::HTTP_CODE_MAP.fetch(status, 'Error')

        fail PanamaxAgent.const_get(class_name).new(
          error['message'],
          error['errorCode'],
          error['cause'])
      end

      private

      def parse_error(body)
        JSON.parse(body)
      rescue StandardError
        { 'message' => body }
      end
    end

    Faraday.register_middleware :response, raise_error: -> { RaiseError }
  end
end
