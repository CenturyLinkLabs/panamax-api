class TemplateRepoSerializer < ActiveModel::Serializer
  self.root = false

  attributes :id, :name, :template_count, :updated_at

  def template_count
    Template.where(source: object.name).count
  end
end
