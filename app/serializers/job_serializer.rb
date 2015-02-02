class JobSerializer < ActiveModel::Serializer
  attributes :id, :key, :name, :completed_steps, :status, :job_template_id

  has_many :steps, serializer: JobStepSerializer

  delegate :completed_steps, :status, to: :object

  def name
    object.job_template.name
  end
end
