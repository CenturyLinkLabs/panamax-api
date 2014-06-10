module AppBuilder
  class FromTemplate

    def self.create_app(options)
      template = Template.find(options[:template_id])

      converter = Converters::TemplateConverter.new(template)
      converter.to_app.tap { |app| app.save }
    end

  end
end
