class JobTemplateSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :documentation, :environment

  has_many :steps, serializer: JobTemplateStepSerializer
end
