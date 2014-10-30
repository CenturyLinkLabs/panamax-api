class RemoteImageSearchResultSerializer < ActiveModel::Serializer
  attributes :source, :description, :is_official, :is_trusted, :star_count, :registry_id, :registry_name

  def source
    object.id
  end
end
