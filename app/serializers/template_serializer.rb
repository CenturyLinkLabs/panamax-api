class TemplateSerializer < ActiveModel::Serializer
  self.root = false

  attributes :id, :name, :description, :keywords, :from, :recommended, :type, :image_count, :created_at, :updated_at

  has_many :images

  def image_count
    object.images.count
  end

end
