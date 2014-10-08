require 'active_resource'

class DeploymentTarget < ActiveRecord::Base
  using FileReader

  validates :name, presence: true, uniqueness: true
  validates_presence_of :cert_file
  validates :auth_blob, auth_blob: true

  before_validation :save_reference
  before_save :write_certificate
  after_destroy :delete_certificate

  def list_deployments
    remote_deployment_model.all
  end

  def get_deployment(deployment_id)
    remote_deployment_model.find(deployment_id)
  end

  def create_deployment(template)
    remote_deployment_model.create(template: template)
  end

  def delete_deployment(deployment_id)
    remote_deployment_model.delete(deployment_id)
  end

  def public_cert
    auth_parts[3].presence || File.read_if_exists(cert_file)
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

  def save_reference
    self.cert_file = "#{PanamaxApi.ssl_certs_dir}#{name.to_s.downcase}.crt"
  end

  def write_certificate
    File.open(cert_file, 'w+') do |f|
      f.write(public_cert)
    end
  end

  def delete_certificate
    FileUtils.rm_f(cert_file.to_s)
  end

  # Class for Deployment model is dynamically generated because we need
  # to be able to set the site at runtime based on the endpoint for the
  # specific deployment target
  def remote_deployment_model
    site_url = self.endpoint_url
    username = self.username
    password = self.password
    cert_file = self.cert_file

    Class.new(RemoteDeployment) do
      self.site = site_url
      self.element_name = 'deployment'
      self.user = username
      self.password = password

      self.ssl_options = {
        verify_mode: OpenSSL::SSL::VERIFY_PEER,
        ca_file: cert_file
      } unless Rails.env.development?
    end
  end
end
