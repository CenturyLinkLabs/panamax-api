module Converters
  class JobTemplateConverter

    def initialize(job_template)
      @job_template = job_template
    end

    def to_job
      job_steps = @job_template.steps.each_with_index.map do |step, i|
        job_step_from_template_step(step, i + 1)
      end

      Job.new(
         job_template: @job_template,
         environment: @job_template.environment,
         steps: job_steps
      )
    end

    private

    def job_step_from_template_step(source, position)
      JobStep.new do |s|
        s.position = position
        s.name = source.name
        s.source = source.source
        s.environment = source.environment
      end
    end

  end
end
