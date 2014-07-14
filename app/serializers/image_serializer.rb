class ImageSerializer < ActiveModel::Serializer
  self.root = false

  attributes :id, :category, :name, :source, :description, :type, :expose, :ports, :links, :environment, :volumes, :command

  def category
    object.categories.first unless object.categories.blank?
  end
end
