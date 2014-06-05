class TemplateFileSerializer < ActiveModel::Serializer
  self.root = false

  attributes :name, :description, :keywords, :recommended, :icon

  has_many :images, serializer: TemplateImageSerializer

end
