class JobLiteSerializer < ActiveModel::Serializer
  attributes :name, :environment

  has_many :steps, serializer: JobStepLiteSerializer

  def name
    object.job_template.name
  end

  def environment
    object.environment
  end
end
