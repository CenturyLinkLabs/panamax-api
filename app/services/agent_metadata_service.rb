class AgentMetadataService < BaseProtectedService
  def find
    response = with_ssl_connection do |connection|
      connection.get "/metadata"
    end

    raise 'metadata not found' if response.status == 404
    RemoteAgentMetadata.new(response.body)
  end
end
