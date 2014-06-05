class TemplateSerializer < ActiveModel::Serializer
  self.root = false

  attributes :id, :name, :description, :keywords, :recommended, :icon, :image_count, :created_at, :updated_at

  has_many :images, serializer: ImageLiteSerializer


  def image_count
    object.images.count
  end

end
