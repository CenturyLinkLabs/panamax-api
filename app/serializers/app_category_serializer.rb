class AppCategorySerializer < ActiveModel::Serializer
  self.root = false

  attributes :id, :name, :position
end
