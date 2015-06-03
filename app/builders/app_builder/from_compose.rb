module AppBuilder
  class FromCompose

    def self.create_app(options)
      options[:name] = 'App From Compose Yaml'
      template = TemplateBuilder.create(options, false)
      unless template.valid?
        raise ArgumentError.new('The Compose YAML provided could not be run.')
      end
      converter = Converters::TemplateConverter.new(template)
      converter.to_app.tap(&:save)
    end

  end
end
