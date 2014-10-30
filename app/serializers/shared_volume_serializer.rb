class SharedVolumeSerializer < ActiveModel::Serializer
  attributes :service_id, :service_name, :errors

  def service_id
    object.exported_from_service.id
  end

  def service_name
    object.exported_from_service.name
  end

end
