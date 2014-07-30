class RepositorySerializer < ActiveModel::Serializer
  self.root = false

  attributes :id, :tags

  def id
    object.id
  end

  def tags
    object.tags
  end
end
