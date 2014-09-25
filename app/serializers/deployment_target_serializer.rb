class DeploymentTargetSerializer < ActiveModel::Serializer
  self.root = false

  attributes :id, :name, :endpoint_url, :auth_blob
end
