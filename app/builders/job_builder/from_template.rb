module JobBuilder
  class FromTemplate

    def self.create_job(options)
      fail 'no template id given' unless options[:job_template_id]

      template = JobTemplate.find(options[:job_template_id])
      if options[:override]
        override = JobTemplateBuilder.create(options[:override], false)
        template.override(override)
      end

      converter = Converters::JobTemplateConverter.new(template)
      converter.to_job.tap(&:save)
    end
  end
end
