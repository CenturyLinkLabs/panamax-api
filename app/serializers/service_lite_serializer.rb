class ServiceLiteSerializer < ActiveModel::Serializer
  self.root = false

  attributes :id, :name, :errors, :icon

  def errors
    object.errors if object.errors.present?
  end

  has_many :categories, serializer: CategorySerializer
end
