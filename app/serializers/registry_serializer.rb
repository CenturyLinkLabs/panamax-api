class RegistrySerializer < ActiveModel::Serializer
  attributes :id, :name, :endpoint_url, :enabled
end
