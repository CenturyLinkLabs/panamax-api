class TemplateRepoSerializer < ActiveModel::Serializer
  attributes :id, :name, :template_count, :updated_at

  def template_count
    Template.where(source: object.name).count
  end
end
