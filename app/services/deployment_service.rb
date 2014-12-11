class DeploymentService < BaseProtectedService

  def all
    response = with_ssl_connection do |connection|
      connection.get '/deployments'
    end

    handle_agent_response(response) do
      response.body.map do |deployment_params|
        RemoteDeployment.new(deployment_params)
      end
    end
  end

  def find(deployment_id)
    response = with_ssl_connection do |connection|
      connection.get "/deployments/#{deployment_id}"
    end

    handle_agent_response(response) { RemoteDeployment.new(response.body) }
  end

  def create(template:, override:)
    response = with_ssl_connection do |connection|
      connection.post '/deployments', {
        template: TemplateFileSerializer.new(template),
        override: TemplateFileSerializer.new(override)
      }.to_json
    end

    handle_agent_response(response) { RemoteDeployment.new(response.body) }
  end

  def destroy(deployment_id)
    response = with_ssl_connection do |connection|
      connection.delete "/deployments/#{deployment_id}"
    end

    handle_agent_response(response)
  end

  def redeploy(deployment_id)
    response = with_ssl_connection do |connection|
      connection.post "/deployments/#{deployment_id}/redeploy"
    end

    handle_agent_response(response) { RemoteDeployment.new(response.body) }
  end

  private

  def handle_agent_response(response)
    case response.status
    when 200..299
      yield if block_given?
    when 404
      raise 'deployment not found'
    else
      raise response.body['message']
    end
  end
end
