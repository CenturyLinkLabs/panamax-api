class JobSerializer < ActiveModel::Serializer
  attributes :id, :key, :completed_steps, :status, :job_template_id

  has_many :steps, serializer: JobStepSerializer

  delegate :completed_steps, :status, to: :object
end
