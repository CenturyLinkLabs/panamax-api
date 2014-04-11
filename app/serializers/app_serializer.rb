class AppSerializer < ActiveModel::Serializer
  self.root = false

  attributes :id, :name, :from

  has_many :services, serializer: ServiceLiteSerializer
end