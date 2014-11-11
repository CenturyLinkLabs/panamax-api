class BaseProtectedService

  def initialize(endpoint_url:, user:, password:, ca_cert:)
    @endpoint_url = endpoint_url
    @user = user
    @password = password
    @ca_cert = ca_cert
  end

  private

  def with_ssl_connection
    file = Tempfile.new('_')
    file.write(@ca_cert)
    file.close
    result = yield(connection(file))
    file.unlink
    result
  end

  def connection(ca_file)

    options = {
      url: @endpoint_url,
      ssl: { ca_file: ca_file.path }
    }

    options[:ssl][:verify_mode] = OpenSSL::SSL::VERIFY_PEER unless Rails.env.development?

    Faraday.new(options) do |faraday|
      faraday.request :basic_auth, @user, @password
      faraday.request :json
      faraday.response :json
      faraday.adapter Faraday.default_adapter
    end
  end
end

