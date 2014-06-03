class TemplateSerializer < ActiveModel::Serializer
  self.root = false

  attributes :id, :name, :description, :keywords, :recommended, :icon

  has_many :images, serializer: TemplateImageSerializer

end
