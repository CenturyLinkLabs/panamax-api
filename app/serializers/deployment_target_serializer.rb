class DeploymentTargetSerializer < ActiveModel::Serializer
  has_one :metadata

  attributes :id, :name, :endpoint_url, :auth_blob
end
