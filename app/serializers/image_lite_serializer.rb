class ImageLiteSerializer < ActiveModel::Serializer
  attributes :id, :image_id, :repository, :tag
end
