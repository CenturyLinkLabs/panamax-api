class TemplateFileSerializer < ActiveModel::Serializer
  self.root = false

  attributes :name, :description, :keywords, :recommended, :icon, :documentation

  has_many :images, serializer: TemplateImageSerializer

  def to_yaml
    as_json.deep_stringify_keys.to_yaml
  end
end
