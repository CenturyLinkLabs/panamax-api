class RemoteImageSearchResultSerializer < ActiveModel::Serializer
  self.root = false

  attributes :source, :description, :is_official, :is_trusted, :star_count

  def source
    object.id
  end

  def description
    object.description
  end

  def is_official
    object.is_official
  end

  def is_trusted
    object.is_trusted
  end

  def star_count
    object.star_count
  end
end
