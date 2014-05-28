class ServiceSerializer < ActiveModel::Serializer
  self.root = false

  attributes :id, :name, :description, :from, :ports, :expose, :environment, :volumes, :load_state,
             :active_state, :sub_state, :icon, :errors

  has_one :app, serializer: AppLiteSerializer

  has_many :categories, serializer: CategorySerializer

  has_many :links, serializer: ServiceLinkSerializer

  def load_state
    service_state[:load_state]
  end

  def active_state
    service_state[:active_state]
  end

  def sub_state
    service_state[:sub_state]
  end

  private

  def service_state
    @service_state ||= object.service_state
  end
end
