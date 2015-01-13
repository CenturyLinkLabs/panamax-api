module Converters
  class JobTemplateConverter

    def initialize(job_template)
      @job_template = job_template
    end

    def to_job
      job_steps = @job_template.steps.each_with_index.map do |step, i|
        job_step_from_job_step(step, i)
      end

      Job.new(
         job_template: @job_template,
         environment: @job_template.environment,
         steps: job_steps
      )
    end

    private

    def job_step_from_job_step(source, order)
      JobStep.new do |s|
        s.order = order
        s.name = source.name
        s.source = source.source
        s.environment = source.environment
      end
    end

  end
end
