module PanamaxAgent
  module Request

    [:get, :head, :put, :post, :delete].each do |method|
      define_method(method) do |path, options={}, headers={}, request_type=:json|
        request(connection(request_type), method, path, options, headers)
      end
    end

    private

    def request(connection, method, path, options, headers)
      options ||= {}

      response = connection.send(method) do |request|
        request.options[:open_timeout] = open_timeout
        request.options[:timeout] = read_timeout
        request.headers = {
          user_agent: user_agent,
          accept: 'application/json'
        }.merge(headers)

        request.path = URI.escape(path)

        case method
        when :delete, :get, :head
          request.params = options unless options.empty?
        when :post, :put
          if options.has_key?(:querystring)
            request.params = options[:querystring]
            request.body = options[:body]
          else
            request.body = options unless options.empty?
          end
        end
      end

      response.body
    end

    private

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
