module JobTemplateBuilder

  def self.create(options, persisted=true)
    steps_hash = options.delete('steps')
    JobTemplate.new(options) do |template|
      template.steps = create_steps(steps_hash) if steps_hash
      template.save if persisted
    end
  end

  def self.create_steps(steps_hash)
    steps_hash.each_with_index.map do |job_step_hash, i|
      JobTemplateStep.new(job_step_hash.merge(order: i + 1))
    end
  end
  private_class_method :create_steps

end
