module AppBuilder
  class FromImage

    def self.create_app(options)
      template = Template.new(name: "#{options[:image]}_image")
      template.images << Image.new(
        name: options[:image],
        source: options[:image]
      )

      converter = Converters::TemplateConverter.new(template)
      converter.to_app.tap { |app| app.save }
    end

  end
end
