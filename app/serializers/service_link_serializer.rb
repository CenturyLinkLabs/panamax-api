class ServiceLinkSerializer < ActiveModel::Serializer
  self.root = false

  attributes :service_id, :service_name, :alias

  def service_id
    object.linked_to_service.id
  end

  def service_name
    object.linked_to_service.name
  end

end

