class TemplateFileSerializer < ActiveModel::Serializer

  class TemplateFileImageSerializer < ActiveModel::Serializer

    attributes :name,
      :source,
      :category,
      :type,
      :expose,
      :ports,
      :links,
      :environment,
      :volumes,
      :volumes_from,
      :command,
      :deployment

    def category
      object.categories.first unless object.categories.blank?
    end

    def attributes
      super.tap do |attrs|
        # Filter out any nil or empty values
        attrs.delete_if { |_, value| value.nil? || value.empty? }
      end
    end
  end

  self.root = false

  attributes :name, :description, :keywords, :type, :documentation

  has_many :images, serializer: TemplateFileImageSerializer

  def to_yaml
    as_json.deep_stringify_keys.to_yaml
  end

end
