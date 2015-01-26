class JobTemplateStepSerializer < ActiveModel::Serializer
  attributes :id, :position, :name, :source, :environment
end
