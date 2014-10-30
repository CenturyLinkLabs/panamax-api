class ImageSerializer < ActiveModel::Serializer
  attributes :id, :category, :name, :source, :description, :type, :expose,
    :ports, :links, :environment, :volumes, :volumes_from, :command

  def category
    object.categories.first unless object.categories.blank?
  end
end
