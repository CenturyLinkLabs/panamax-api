class JobLiteSerializer < ActiveModel::Serializer
  attributes :name, :environment

  has_many :steps, serializer: JobStepLiteSerializer

  def name
    object.job_template.name
  end

  def environment
    return nil unless object.environment
    object.environment.each_with_object([]) do |env_vars, arr|
      arr << env_vars.each_with_object({}) do |(key, value), result|
        result[key] = value.to_s
      end
    end
  end
end
