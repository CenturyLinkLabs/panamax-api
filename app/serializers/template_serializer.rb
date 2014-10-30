class TemplateSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :keywords, :source, :type, :image_count, :created_at, :updated_at,
             :documentation

  has_many :images

  def image_count
    object.images.count
  end

end
