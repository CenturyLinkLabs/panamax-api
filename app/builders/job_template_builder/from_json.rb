module JobTemplateBuilder
  class FromJson

    attr_reader :params

    def initialize(template_contents)
      @params = YAML.safe_load(template_contents || '')
    end

    def create_template(persisted=true)
      steps_hash = params.delete('steps')
      JobTemplate.new(params) do |template|
        template.steps = create_steps(steps_hash) if steps_hash
        template.save if persisted
      end
    end

    private
    def create_steps(steps_hash)
      steps_hash.each_with_index.map do |job_step_hash, i|
        JobStep.new(job_step_hash.merge(order: i))
      end
    end
  end
end
