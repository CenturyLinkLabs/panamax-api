class ServiceSerializer < ActiveModel::Serializer
  self.root = false

  attributes :id, :name, :description, :from, :ports, :expose, :environment, :volumes, :load_state,
             :active_state, :sub_state, :icon

  has_one :app, serializer: AppLiteSerializer

  has_many :categories, serializer: CategorySerializer

  has_many :links, serializer: ServiceLinkSerializer
end
