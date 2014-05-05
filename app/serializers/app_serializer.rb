class AppSerializer < ActiveModel::Serializer
  self.root = false

  attributes :id, :name, :from, :errors

  has_many :categories, serializer: CategorySerializer
  has_many :services, serializer: ServiceLiteSerializer

  def errors
    object.errors.delete(:services) if object.errors.has_key?(:services)
    object.errors if object.errors.present?
  end
end