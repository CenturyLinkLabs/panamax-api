class TemplateSerializer < ActiveModel::Serializer
  self.root = false

  attributes :id, :name, :description, :keywords, :recommended, :icon, :created_at, :updated_at

  has_many :images, serializer: ImageLiteSerializer
end
