class ServiceSerializer < ActiveModel::Serializer
  self.root = false

  attributes :id, :name, :description, :from, :links, :ports, :expose, :environment, :volumes, :load_state,
             :active_state, :sub_state

  has_one :app, serializer: AppLiteSerializer
end