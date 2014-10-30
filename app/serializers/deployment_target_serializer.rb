class DeploymentTargetSerializer < ActiveModel::Serializer
  attributes :id, :name, :endpoint_url, :auth_blob
end
