module PanamaxAgent
  module Request

    [:get, :head, :put, :post, :delete].each do |method|
      define_method(method) do |path, options={}, headers={}|
        request(connection, method, path, options, headers)
      end
    end

    private

    def request(connection, method, path, options, headers)
      options ||= {}

      response = connection.send(method) do |request|
        request.options[:open_timeout] = open_timeout
        request.options[:timeout] = read_timeout
        request.path = URI.escape(path)
        request.headers = headers
        case method
        when :delete, :get, :head
          request.params = options unless options.empty?
        when :post, :put
          request.body = options unless options.empty?
        end
      end

      response.body
    end
  end
end
