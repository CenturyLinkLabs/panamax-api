module DeploymentTarget::Deployments
  def list_deployments
    with_remote_deployment_model do |model|
      model.all
    end
  end

  def get_deployment(deployment_id)
    with_remote_deployment_model do |model|
      model.find(deployment_id)
    end
  end

  def create_deployment(template, override)
    with_remote_deployment_model do |model|
      model.create(
        template: TemplateFileSerializer.new(template),
        override: TemplateFileSerializer.new(override))
    end
  end

  def delete_deployment(deployment_id)
    with_remote_deployment_model do |model|
      model.delete(deployment_id)
    end
  end

protected

  def with_remote_deployment_model
    Tempfile.open(name.to_s.downcase) do |file|
      file.write(public_cert)
      file.rewind
      yield(remote_deployment_model(file))
    end
  end

  # Class for Deployment model is dynamically generated because we need
  # to be able to set the site at runtime based on the endpoint for the
  # specific deployment target
  def remote_deployment_model(cert_file)
    target = self

    Class.new(RemoteDeployment) do
      self.site = target.endpoint_url
      self.element_name = 'deployment'
      self.user = target.username
      self.password = target.password

      self.ssl_options = {
        verify_mode: OpenSSL::SSL::VERIFY_PEER,
        ca_file: cert_file.path
      } unless Rails.env.development?
    end
  end
end
