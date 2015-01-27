class JobStepSerializer < ActiveModel::Serializer
  attributes :id, :order, :name, :source, :environment
end
