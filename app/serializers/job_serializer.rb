class JobSerializer < ActiveModel::Serializer
  attributes :id, :key, :completed_steps, :status

  has_many :steps, serializer: JobStepSerializer

  def completed_steps
    object.completed_steps
  end

  def status
    object.status
  end
end
