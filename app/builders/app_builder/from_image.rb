module AppBuilder
  class FromImage

    def self.create_app(options)
      template = Template.new(name: "#{options[:image]}_image")
      registry = Registry.find_by_id(options[:registry_id])
      template.images << Image.new(
        name: options[:image],
        source: "#{registry.try(:prefix)}#{options[:image]}"
      )

      converter = Converters::TemplateConverter.new(template)
      converter.to_app.tap { |app| app.save }
    end

  end
end
