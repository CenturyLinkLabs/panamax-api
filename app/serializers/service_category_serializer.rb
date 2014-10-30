class ServiceCategorySerializer < ActiveModel::Serializer
  attributes :id, :name, :position

  def id
    object.app_category_id
  end
end
