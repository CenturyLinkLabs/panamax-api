class ServiceCategorySerializer < ActiveModel::Serializer
  self.root = false

  attributes :id, :name, :position

  def id
    object.app_category_id
  end
end
