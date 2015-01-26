class JobSerializer < ActiveModel::Serializer
  attributes :id, :key, :completed_steps, :status

  has_many :steps, serializer: JobStepSerializer

  delegate :completed_steps, :status, to: :object
end
