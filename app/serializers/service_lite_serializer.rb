class ServiceLiteSerializer < ActiveModel::Serializer
  attributes :id, :name, :errors

  def errors
    object.errors if object.errors.present?
  end
end