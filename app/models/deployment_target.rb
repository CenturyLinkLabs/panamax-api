require 'active_resource'

class DeploymentTarget < ActiveRecord::Base
  using FileReader

  validates :name, presence: true, uniqueness: true
  validates_presence_of :cert_file
  validates :auth_blob, auth_blob: true

  def list_deployments
    remote_deployment_model.all
  end

  def get_deployment(deployment_id)
    remote_deployment_model.find(deployment_id)
  end

  def create_deployment(template, override)
    remote_deployment_model.create(
      template: TemplateFileSerializer.new(template),
      override: TemplateFileSerializer.new(override))
  end

  def delete_deployment(deployment_id)
    remote_deployment_model.delete(deployment_id)
  end

  def public_cert
    auth_parts[3]
  end

  def cert_file
    unless @cert_file
      @cert_file = Tempfile.new(name.to_s.downcase)
      @cert_file.write(public_cert)
      @cert_file.close
    end
    @cert_file
  end

  def endpoint_url
    auth_parts[0]
  end

  def username
    auth_parts[1]
  end

  def password
    auth_parts[2]
  end

  private

  def auth_parts
    Base64.decode64(auth_blob.to_s).split('|')
  end

  # Class for Deployment model is dynamically generated because we need
  # to be able to set the site at runtime based on the endpoint for the
  # specific deployment target
  def remote_deployment_model
    site_url = self.endpoint_url
    username = self.username
    password = self.password
    cert_file_path = self.cert_file.path

    Class.new(RemoteDeployment) do
      self.site = site_url
      self.element_name = 'deployment'
      self.user = username
      self.password = password

      self.ssl_options = {
        verify_mode: OpenSSL::SSL::VERIFY_PEER,
        ca_file: cert_file_path
      } unless Rails.env.development?
    end
  end
end
