class ServiceSerializer < ActiveModel::Serializer
  self.root = false

  attributes :id, :name, :description, :from, :links, :ports, :expose, :environment, :volumes

  has_one :app, serializer: AppLiteSerializer

  has_many :categories, serializer: CategorySerializer
end
