class RemoteImageSearchResultSerializer < ActiveModel::Serializer
  self.root = false

  attributes :source, :description, :is_official, :is_trusted, :star_count

  def source
    object.id
  end
end
