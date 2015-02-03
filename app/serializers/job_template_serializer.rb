class JobTemplateSerializer < ActiveModel::Serializer
  attributes :id, :name, :vendor, :adapter, :description, :documentation, :environment

  has_many :steps, serializer: JobTemplateStepSerializer
end
