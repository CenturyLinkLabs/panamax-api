module RemoteAgentResponseHelpers
  def stub_agent_metadata_request(deployment_target, metadata: {}, status: 200)
    path = "/metadata"
    stub_request(:get, /#{path}$/).to_return(
      body: metadata.to_json,
      status: 200
    )
  end
end


RSpec.configure do |c|
  c.include RemoteAgentResponseHelpers
end
