class DeploymentTarget < ActiveRecord::Base
  include Metadata
  using FileReader

  validates :name, presence: true
  validates :auth_blob, auth_blob: true

  def public_cert
    auth_parts[3]
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

  def new_agent_service(klass)
    klass.new(
      endpoint_url: endpoint_url,
      ca_cert: public_cert,
      user: username,
      password: password
    )
  end

  private

  def auth_parts
    Base64.decode64(auth_blob.to_s).split('|')
  end
end
