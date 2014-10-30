class RepositorySerializer < ActiveModel::Serializer
  attributes :id, :tags

  def id
    object.id
  end

  def tags
    object.tags
  end
end
