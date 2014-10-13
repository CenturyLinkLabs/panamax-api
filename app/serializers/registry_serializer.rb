class RegistrySerializer < ActiveModel::Serializer
  self.root = false

  attributes :id, :name, :endpoint_url, :enabled
end
