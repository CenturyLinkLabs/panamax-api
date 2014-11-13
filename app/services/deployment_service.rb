class DeploymentService < BaseProtectedService

  def all
    response = with_ssl_connection do |connection|
      connection.get '/deployments'
    end

    response.body.map do |deployment_params|
      RemoteDeployment.new(deployment_params)
    end
  end

  def find(deployment_id)
    response = with_ssl_connection do |connection|
      connection.get "/deployments/#{deployment_id}"
    end

    raise 'deployment not found' if response.status == 404
    RemoteDeployment.new(response.body)
  end

  def create(template:, override:)
    response = with_ssl_connection do |connection|
      connection.post '/deployments', {
        template: TemplateFileSerializer.new(template),
        override: TemplateFileSerializer.new(override)
      }.to_json
    end

    RemoteDeployment.new(response.body)
  end

  def destroy(deployment_id)
    with_ssl_connection do |connection|
      connection.delete "/deployments/#{deployment_id}"
    end
  end
end
