class ServiceSerializer < ActiveModel::Serializer
  self.root = false

  attributes :id, :name, :description, :from, :ports, :expose, :default_exposed_ports, :environment,
    :volumes, :command, :load_state, :active_state, :sub_state, :type, :errors,
    :docker_status

  has_one :app, serializer: AppLiteSerializer

  has_many :categories, serializer: ServiceCategorySerializer

  has_many :links, serializer: ServiceLinkSerializer

  has_many :volumes_from, serializer: SharedVolumeSerializer

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
