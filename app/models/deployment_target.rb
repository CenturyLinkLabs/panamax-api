class DeploymentTarget < ActiveRecord::Base
  include Deployments
  using FileReader

  validates :name, presence: true, uniqueness: true
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

  private

  def auth_parts
    Base64.decode64(auth_blob.to_s).split('|')
  end
end
